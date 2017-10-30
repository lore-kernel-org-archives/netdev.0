From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: Avoid calling
 platform_device_put() twice in bcmgenet_mii_exit()
Date: Mon, 30 Oct 2017 12:32:24 -0700
Message-ID: <7bf1c138-a6ad-6bae-9108-a7758c7f9973@gmail.com>
References: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Wei Yongjun <weiyongjun1@huawei.com>,
        Doug Berger <opendmb@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:54730 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932143AbdJ3Tc3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 15:32:29 -0400
Received: by mail-qt0-f194.google.com with SMTP id z19so17867252qtg.11
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 12:32:29 -0700 (PDT)
In-Reply-To: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2017 10:05 PM, Wei Yongjun wrote:
> Remove platform_device_put() call after platform_device_unregister()
> from function bcmgenet_mii_exit(), otherwise, we will call
> platform_device_put() twice.
> 
> Fixes: 9a4e79697009 ("net: bcmgenet: utilize generic Broadcom UniMAC
> MDIO controller driver")

Please don't force a wrap to 80 columns for commit subjects.

> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  drivers/net/ethernet/broadcom/genet/bcmmii.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> index ba3fcfd..5333274 100644
> --- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
> +++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
> @@ -571,5 +571,4 @@ void bcmgenet_mii_exit(struct net_device *dev)
>  		of_phy_deregister_fixed_link(dn);
>  	of_node_put(priv->phy_dn);
>  	platform_device_unregister(priv->mii_pdev);
> -	platform_device_put(priv->mii_pdev);
>  }
> 


-- 
Florian
