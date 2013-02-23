From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4_en: fix allocation of CPU affinity reverse-map
Date: Sat, 23 Feb 2013 13:54:29 -0500 (EST)
Message-ID: <20130223.135429.1335162102680714009.davem@davemloft.net>
References: <1361596492-10565-1-git-send-email-klebers@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, netdev@vger.kernel.org
To: klebers@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757882Ab3BWSye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2013 13:54:34 -0500
In-Reply-To: <1361596492-10565-1-git-send-email-klebers@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>
Date: Sat, 23 Feb 2013 02:14:52 -0300

> The mlx4_en driver allocates the number of objects for the CPU affinity
> reverse-map based on the number of rx rings of the device. However,
> mlx4_assign_eq() calls irq_cpu_rmap_add() as many times as IRQ's are
> assigned to EQ's, which can be as large as mlx4_dev->caps.comp_pool. If
> caps.comp_pool is larger than rx_ring_num we will eventually hit the
> BUG_ON() in cpu_rmap_add().
> 
> Fix this problem by allocating space for the maximum number of CPU
> affinity reverse-map objects we might want to add.
> 
> Signed-off-by: Kleber Sacilotto de Souza <klebers@linux.vnet.ibm.com>

Applied.
