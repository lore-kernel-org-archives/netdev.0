From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH -next] drivers: net: phy: xgene: Remove redundant dev_err
 call in xgene_mdio_probe()
Date: Thu, 28 Jul 2016 13:42:18 -0700
Message-ID: <CAKh23Fmc=a0PNLtLMD=0e4_As7=E4YMyMu3NF4_2iVa2Hxtngg@mail.gmail.com>
References: <1469671937-13265-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Keyur Chudgar <kchudgar@apm.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f52.google.com ([209.85.213.52]:34477 "EHLO
	mail-vk0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753273AbcG1UmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 16:42:20 -0400
Received: by mail-vk0-f52.google.com with SMTP id s189so40653810vkh.1
        for <netdev@vger.kernel.org>; Thu, 28 Jul 2016 13:42:20 -0700 (PDT)
In-Reply-To: <1469671937-13265-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 27, 2016 at 7:12 PM, Wei Yongjun <weiyj.lk@gmail.com> wrote:
> There is a error message within devm_ioremap_resource
> already, so remove the dev_err call to avoid redundant
> error message.
>
> Signed-off-by: Wei Yongjun <weiyj.lk@gmail.com>
> ---
>  drivers/net/phy/mdio-xgene.c | 4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
>
> diff --git a/drivers/net/phy/mdio-xgene.c b/drivers/net/phy/mdio-xgene.c
> index d94a978..7756748 100644
> --- a/drivers/net/phy/mdio-xgene.c
> +++ b/drivers/net/phy/mdio-xgene.c
> @@ -345,10 +345,8 @@ static int xgene_mdio_probe(struct platform_device *pdev)
>
>         res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>         csr_base = devm_ioremap_resource(dev, res);
> -       if (IS_ERR(csr_base)) {
> -               dev_err(dev, "Unable to retrieve mac CSR region\n");
> +       if (IS_ERR(csr_base))
>                 return PTR_ERR(csr_base);
> -       }
>         pdata->mac_csr_addr = csr_base;
>         pdata->mdio_csr_addr = csr_base + BLOCK_XG_MDIO_CSR_OFFSET;
>         pdata->diag_csr_addr = csr_base + BLOCK_DIAG_CSR_OFFSET;
>
>
>

Thanks.

Acked-By: Iyappan Subramanian <isubramanian@apm.com>
