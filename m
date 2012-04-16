From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] drivers/net: fix unresolved 64bit math in
 mellanox/mlx4/en_dcb_nl.c
Date: Mon, 16 Apr 2012 02:12:40 -0400 (EDT)
Message-ID: <20120416.021240.1294096210590640473.davem@davemloft.net>
References: <20120415.233139.452372897242947075.davem@davemloft.net>
	<1334549854-16370-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40975 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892Ab2DPGMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2012 02:12:49 -0400
In-Reply-To: <1334549854-16370-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 16 Apr 2012 00:17:34 -0400

> Commit 109d2446052a484c58f07f71f9457bf7b71017f8
> 
>     "net/mlx4_en: Set max rate-limit for a TC"
> 
> introduced 64 bit math operations into mlx4_en_dcbnl_ieee_setmaxrate()
> 
> causing the following final link failure on an x86_32 allmodconfig
> 
>   ERROR: "__udivdi3" [drivers/net/ethernet/mellanox/mlx4/mlx4_en.ko] undefined!
> 
> Convert it to use div_u64() instead.
> 
> Cc: Amir Vadai <amirv@mellanox.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks Paul.
