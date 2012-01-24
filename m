From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: RE: [net PATCH 1/1] qlge:Changing netdev msg level to default debug
Date: Tue, 24 Jan 2012 10:30:27 -0800
Message-ID: <5E4F49720D0BAD499EE1F01232234BA874379FBF1D@AVEXMB1.qlogic.org>
References: <1327361932-28774-1-git-send-email-jitendra.kalsaria@qlogic.com>
 <CANX6DanOS=SRcFsrRmezggZkXLXkBY3cMtNss3ey9rv-9WPahg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept-NX Linux NIC Driver
	<Dept_NX_Linux_NIC_Driver@qlogic.com>
To: Viral Mehta <viral.vkm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe001.messaging.microsoft.com ([216.32.181.181]:34575
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756192Ab2AXSao convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jan 2012 13:30:44 -0500
In-Reply-To: <CANX6DanOS=SRcFsrRmezggZkXLXkBY3cMtNss3ey9rv-9WPahg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Viral,

Thanks and yes I want to initialize with 0x111. Sorry about my typo err=
or in commit log, I should have said debug level shift to 3.

Jiten

-----Original Message-----
=46rom: Viral Mehta [mailto:viral.vkm@gmail.com]=20
Sent: Tuesday, January 24, 2012 8:52 AM
To: Jitendra Kalsaria
Cc: David Miller; netdev; Ron Mercer; Dept-NX Linux NIC Driver
Subject: Re: [net PATCH 1/1] qlge:Changing netdev msg level to default =
debug

Hi,

On Mon, Jan 23, 2012 at 6:38 PM, Jitendra Kalsaria
<jitendra.kalsaria@qlogic.com> wrote:

> -static const u32 default_msg =3D
> - =A0 =A0NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK |
> -/* NETIF_MSG_TIMER | =A0 */
> - =A0 =A0NETIF_MSG_IFDOWN |
> - =A0 =A0NETIF_MSG_IFUP |
> - =A0 =A0NETIF_MSG_RX_ERR |
> - =A0 =A0NETIF_MSG_TX_ERR |
> -/* =A0NETIF_MSG_TX_QUEUED | */
> -/* =A0NETIF_MSG_INTR | NETIF_MSG_TX_DONE | NETIF_MSG_RX_STATUS | */
> -/* NETIF_MSG_PKTDATA | */
> - =A0 =A0NETIF_MSG_HW | NETIF_MSG_WOL | 0;
> -
> -static int debug =3D -1; /* defaults above */
> +#define DEFAULT_DEBUG_MSG_LEVEL 3
> +static int debug =3D DEFAULT_DEBUG_MSG_LEVEL;
> =A0module_param(debug, int, 0664);
> =A0MODULE_PARM_DESC(debug, "Debug level (0=3Dnone,...,16=3Dall)");
>
> @@ -4614,7 +4603,7 @@ static int __devinit ql_init_device(struct pci_=
dev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -EIO;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_out2;
> =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 qdev->msg_enable =3D netif_msg_init(debug, default_msg)=
;
> + =A0 =A0 =A0 qdev->msg_enable =3D netif_msg_init(debug, DEFAULT_DEBU=
G_MSG_LEVEL);

Do you want to initialize qdev->msg_enable with 0x11 ?
(I assume this based on above line where you initialized debug with 3
(decimal value))

If so, the above line will initialize with 0x111
As per netif_msg_init function (1 << 3 ) -1

Poiniting out because it can be a mistake in hurry.
If not, and you think what you have done is
what you wanted to do then sorry for the noise

But would like to read more clear commit log message.

--=20
Thanks,
Viral Mehta
