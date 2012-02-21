From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlx4: Replacing pool_lock with mutex
Date: Tue, 21 Feb 2012 15:28:26 -0500 (EST)
Message-ID: <20120221.152826.28693031857253840.davem@davemloft.net>
References: <4F439E94.60807@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754298Ab2BUU2i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2012 15:28:38 -0500
In-Reply-To: <4F439E94.60807@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 21 Feb 2012 15:39:32 +0200

> 
> Under the spinlock we call request_irq(), which allocates memory with GFP_KERNEL,
> This causes the following trace when DEBUG_SPINLOCK is enabled, it can cause
> the following trace:
 ...
> Replacing with mutex, which is enough in this case.
> 
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>

Applied.
