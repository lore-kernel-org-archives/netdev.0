From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4_en: Convert the normal skb free path to
 dev_consume_skb_any()
Date: Wed, 03 Sep 2014 21:00:44 -0700 (PDT)
Message-ID: <20140903.210044.1260502858382972070.davem@davemloft.net>
References: <20140903161800.301F629002CD@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52020 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750788AbaIDD7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 23:59:42 -0400
In-Reply-To: <20140903161800.301F629002CD@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Wed,  3 Sep 2014 09:18:00 -0700 (PDT)

> From: Rick Jones <rick.jones2@hp.com>
> 
> It would appear the mlx4_en driver was still making a call to
> dev_kfree_skb_any() where dev_consume_skb_any() would be more
> appropriate.  This should make dropped packet profiling/tracking
> easier/better over a NIC driven by mlx4_en.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>

Applied, thank you.
