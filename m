From: Manish Katiyar <mkatiyar@gmail.com>
Subject: Re: [PATCH] : Remove unused variable pdev from drivers/net/r6040.c
Date: Tue, 27 Jan 2009 09:58:11 +0530
Message-ID: <ea11fea30901262028r3a8f694fgd03b9bf7538719b3@mail.gmail.com>
References: <ea11fea30901190529k6f12f4c1xed7295ccbf0dcefa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: mkatiyar@gmail.com, David Miller <davem@davemloft.net>,
	stable@vger.kernel.org
To: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	sten.wang@rdc.com.tw, daniel@gimpelevich.san-francisco.ca.us,
	florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:28163 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751307AbZA0E2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 23:28:13 -0500
In-Reply-To: <ea11fea30901190529k6f12f4c1xed7295ccbf0dcefa@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Adding david miller and stable@kernel.org in cc ]

Thanks -
Manish

On Mon, Jan 19, 2009 at 6:59 PM, Manish Katiyar <mkatiyar@gmail.com> wrote:
> Below patch removes the following compilation warning.
>
> drivers/net/r6040.c:441: warning: unused variable 'pdev'
>
>
> Signed-off-by : Manish Katiyar <mkatiyar@gmail.com>
> ---
>  drivers/net/r6040.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
> index 72fd9e9..b2dcdb5 100644
> --- a/drivers/net/r6040.c
> +++ b/drivers/net/r6040.c
> @@ -438,7 +438,6 @@ static void r6040_down(struct net_device *dev)
>  {
>        struct r6040_private *lp = netdev_priv(dev);
>        void __iomem *ioaddr = lp->base;
> -       struct pci_dev *pdev = lp->pdev;
>        int limit = 2048;
>        u16 *adrp;
>        u16 cmd;
> --
> 1.5.4.3
>
>
> Thanks -
> Manish
>
