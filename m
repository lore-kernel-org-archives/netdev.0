From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 5/8] bnx2x: Change Warpcore MDIO work around mode
Date: Sun, 27 Nov 2011 17:03:45 -0500 (EST)
Message-ID: <20111127.170345.210055753705612508.davem@davemloft.net>
References: <1322417881-17760-1-git-send-email-yanivr@broadcom.com>
	<1322417881-17760-6-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: yanivr@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755726Ab1K0WDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2011 17:03:48 -0500
In-Reply-To: <1322417881-17760-6-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Yaniv Rosner" <yanivr@broadcom.com>
Date: Sun, 27 Nov 2011 20:17:58 +0200

> @@ -11308,7 +11308,9 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
>  				       offsetof(struct shmem_region,
>  			dev_info.port_feature_config[port].link_config)) &
>  			  PORT_FEATURE_CONNECTED_SWITCH_MASK);
> -	chip_id = REG_RD(bp, MISC_REG_CHIP_NUM) << 16;
> +	chip_id = (REG_RD(bp, MISC_REG_CHIP_NUM) << 16) |
> +				((REG_RD(bp, MISC_REG_CHIP_REV) & 0xf) << 12);
> +

Bad formatting.
