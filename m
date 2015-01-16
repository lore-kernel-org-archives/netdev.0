From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4: Don't disable vxlan offloads under
 DMFS-A0 optimized steering
Date: Thu, 15 Jan 2015 19:35:57 -0500 (EST)
Message-ID: <20150115.193557.348020366326523895.davem@davemloft.net>
References: <1421328534-14216-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matanb@mellanox.com, amirv@mellanox.com
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56080 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752368AbbAPAf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 19:35:59 -0500
In-Reply-To: <1421328534-14216-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Thu, 15 Jan 2015 15:28:54 +0200

> Except for VXLAN steering rules, all offloads should work as they were
> under plain DMFS mode. Fix that by enabling all the offloads under
> DMFS-A0 mode, except for VXLAN steering rules.
> 
> Fixes: d57febe1a478 "net/mlx4: Add A0 hybrid steering"
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>

Applied, thanks.
