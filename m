From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: mlx4_en_set_settings() always
 fails when autoneg is set
Date: Fri, 21 Nov 2014 15:08:50 -0500 (EST)
Message-ID: <20141121.150850.1419027477033247999.davem@davemloft.net>
References: <1416485984-5029-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, yevgenyp@mellanox.com,
	netdev@vger.kernel.org, saeedm@mellanox.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934AbaKUUIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 15:08:53 -0500
In-Reply-To: <1416485984-5029-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Thu, 20 Nov 2014 14:19:44 +0200

> From: Saeed Mahameed <saeedm@mellanox.com>
> 
> Fix ethtool set settings to not check AUTONEG_ENABLE
> 
> mlx4_en_set_settings should not check if cmd->autoneg == AUTONEG_ENABLE,
> cmd->autoneg can be enabled by default and this check will fail other settings requests.
> mlx4_en driver doesn't support changing autoneg value, but shouldn't fail the request
> in case cmd->autoneg was set.
> 
> Fixes: d48b3ab ("net/mlx4_en: Use PTYS register to set ethtool settings (Speed)")
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> Signed-off-by: Amir Vadai <amirv@mellanox.com>

Applied, thanks.
