From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH 01/10] atl1c: add workaround for issue of bit INTX-disable
 for MSI interrupt
Date: Sat, 28 Apr 2012 10:21:40 -0700
Message-ID: <CAB=NE6VhF=nj8-n_QY339VOzQUEPZsSzsOd7Q2TwgyUywzdjNA@mail.gmail.com>
References: <1335578325-21326-1-git-send-email-xiong@qca.qualcomm.com>
 <1335578325-21326-2-git-send-email-xiong@qca.qualcomm.com>
 <20120428020510.GJ14465@tux> <157393863283F442885425D2C454285623D5F96D@nasanexd02a.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:64560 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754622Ab2D1RWC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 13:22:02 -0400
In-Reply-To: <157393863283F442885425D2C454285623D5F96D@nasanexd02a.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 28, 2012 at 2:53 AM, Huang, Xiong <xiong@qca.qualcomm.com> =
wrote:
> Thanks Luis, =C2=A0just one question:
>
> I don't know which kernel version contains the updated pci/quirks.c, =
so,
> if I write the patch file (a 58-drivers-pci-quirks.patch) as:
>
> --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
>
> +#if (LINUX_VERSION_CODE >=3D KERNEL_VERSION(2,6,22))
> + =C2=A0 =C2=A0 =C2=A0 pdev->dev_flags |=3D PCI_DEV_FLAGS_MSI_INTX_DI=
SABLE_BUG;
> +#endif
>
>
> It seems not good for the kernel with updated pci/quirks.c
>
> Any better suggestion ? thanks

That looks good for the backport, you would just ifdef around <
KERNEL_VERSION(3,5,0)

  Luis
