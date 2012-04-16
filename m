From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: fix unresolved 64bit math in
 mellanox/mlx4/en_dcb_nl.c
Date: Sun, 15 Apr 2012 23:31:39 -0400 (EDT)
Message-ID: <20120415.233139.452372897242947075.davem@davemloft.net>
References: <1334545794-16703-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40188 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101Ab2DPDbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Apr 2012 23:31:48 -0400
In-Reply-To: <1334545794-16703-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Sun, 15 Apr 2012 23:09:54 -0400

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

Please add an explicit linux/math64.h include here too, thanks.
