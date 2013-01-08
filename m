From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: net: usb: cdc_ncm: add support  IFF_NOARP
Date: Tue, 08 Jan 2013 22:27:51 +0000
Message-ID: <9d3b0a25-0aef-4bf6-b7c9-e00c6ada73cf@email.android.com>
References: <001601cdeda2$2547a6b0$6fd6f410$@com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: Wei Shuai <cpuwolf@gmail.com>,
	"'Greg Kroah-Hartman'" <gregkh@linuxfoundation.org>,
	"'Alexey Orishko'" <alexey.orishko@stericsson.com>,
	"'Hans Petter Selasky'" <hans.petter.selasky@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:35703 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753851Ab3AHW2N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 17:28:13 -0500
In-Reply-To: <001601cdeda2$2547a6b0$6fd6f410$@com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Shuai <cpuwolf@gmail.com> wrote:

>Hi Alexey,
>	Recently I met a Modem which cannot do ARP. But I found our
>cdc_ncm_bind() function cannot handle this special case. Do you have
>any
>plan to handle it?
>
>
>static int cdc_ncm_bind(struct usbnet *dev, struct usb_interface *intf=
)
>{
>	...
> 	/*  cannot do ARP */
> 	dev->net->flags |=3D IFF_NOARP;
>	...
>}
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-usb" i=
n
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html

Are you sure all CDC NCM devices will handle this? Maybe the buggy devi=
ce need a device specific quirk instead?=20


Bj=C3=B8rn
