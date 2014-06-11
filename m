From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [patch] amd-xgbe: unwind on error in xgbe_mdio_register()
Date: Wed, 11 Jun 2014 08:15:39 -0500
Message-ID: <5398567B.2090607@amd.com>
References: <20140611065626.GC16443@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0236.outbound.protection.outlook.com ([207.46.163.236]:2468
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755635AbaFKNPt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Jun 2014 09:15:49 -0400
In-Reply-To: <20140611065626.GC16443@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/11/2014 01:56 AM, Dan Carpenter wrote:
> There is a typo here so we return directly instead of unwinding.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Tom Lendacky <thomas.lendacky@amd.com>

>
> diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
> index 52bbdbf..ea7a5d6 100644
> --- a/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
> +++ b/drivers/net/ethernet/amd/xgbe/xgbe-mdio.c
> @@ -367,7 +367,7 @@ int xgbe_mdio_register(struct xgbe_prv_data *pdata)
>
>   	if (!phydev->drv || (phydev->drv->phy_id == 0)) {
>   		netdev_err(netdev, "phy_id not valid\n");
> -		return -ENODEV;
> +		ret = -ENODEV;
>   		goto err_phy_connect;
>   	}
>   	DBGPR("  phy_connect_direct succeeded for PHY %s, link=%d\n",
>
