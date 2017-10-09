From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 3/3] net: phy: Change error to EINVAL for invalid MAC
Date: Mon, 9 Oct 2017 09:47:14 -0700
Message-ID: <bafce8fe-ed85-bfce-3231-ec61eb99e668@gmail.com>
References: <20171009120302.23611-1-dmurphy@ti.com>
 <20171009120302.23611-3-dmurphy@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Woojung.Huh@microchip.com, afd@ti.com
To: Dan Murphy <dmurphy@ti.com>, andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:53655 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754626AbdJIQrS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 12:47:18 -0400
Received: by mail-qt0-f193.google.com with SMTP id n61so16313118qte.10
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 09:47:17 -0700 (PDT)
In-Reply-To: <20171009120302.23611-3-dmurphy@ti.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2017 05:03 AM, Dan Murphy wrote:
> Change the return error code to EINVAL if the MAC
> address is not valid in the set_wol function.

Looks fine to me, since you are respining, do you mind using "net: phy:
at803x:  Change error to EINVAL for invalid MAC" as a subject to further
specify what this is about?

Thanks!

> 
> Signed-off-by: Dan Murphy <dmurphy@ti.com>
> ---
> 
> v3 - No changes made
> v2 - There was no v1 on this patch this is new.
> 
>  drivers/net/phy/at803x.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index c1e52b9dc58d..5f93e6add563 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -167,7 +167,7 @@ static int at803x_set_wol(struct phy_device *phydev,
>  		mac = (const u8 *) ndev->dev_addr;
>  
>  		if (!is_valid_ether_addr(mac))
> -			return -EFAULT;
> +			return -EINVAL;
>  
>  		for (i = 0; i < 3; i++) {
>  			phy_write(phydev, AT803X_MMD_ACCESS_CONTROL,
> 


-- 
Florian
