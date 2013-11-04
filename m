From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_core: Fix call to __mlx4_unregister_mac
Date: Mon, 04 Nov 2013 00:51:56 -0500 (EST)
Message-ID: <20131104.005156.1967990418615590560.davem@davemloft.net>
References: <1383465847-28719-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48821 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822Ab3KDFwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Nov 2013 00:52:00 -0500
In-Reply-To: <1383465847-28719-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun,  3 Nov 2013 10:04:07 +0200

> From: Jack Morgenstein <jackm@dev.mellanox.co.il>
> 
> In function mlx4_master_deactivate_admin_state() __mlx4_unregister_mac was
> called using the MAC index. It should be called with the value of the MAC itself.
> 
> Signed-off-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied and queued up for -stable, thanks.
