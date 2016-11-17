From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [patch] amd-xgbe: Signedness bug in xgbe_phy_link_status()
Date: Thu, 17 Nov 2016 08:40:29 -0600
Message-ID: <e7d2e620-9eb0-0fee-1d6f-33062fd8bcc7@amd.com>
References: <20161117105932.GA32143@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0078.outbound.protection.outlook.com ([104.47.34.78]:32480
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933208AbcKQRN0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 17 Nov 2016 12:13:26 -0500
In-Reply-To: <20161117105932.GA32143@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 4:59 AM, Dan Carpenter wrote:
> "ret" needs to be signed for the error handling to work.
> 
> Fixes: abf0a1c2b26a ("amd-xgbe: Add support for SFP+ modules")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> 

Hi Dan,

This was already identified and patched:
8c5385cbb036 ("amd-xgbe: Fix up some coccinelle identified warnings")

Thanks,
Tom

> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> index 4ba4332..a2559c2 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-phy-v2.c
> @@ -2346,7 +2346,8 @@ static bool xgbe_phy_valid_speed(struct xgbe_prv_data *pdata, int speed)
>  static int xgbe_phy_link_status(struct xgbe_prv_data *pdata, int *an_restart)
>  {
>  	struct xgbe_phy_data *phy_data = pdata->phy_data;
> -	unsigned int ret, reg;
> +	unsigned int reg;
> +	int ret;
>  
>  	*an_restart = 0;
>  
> 
