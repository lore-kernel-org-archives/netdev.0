From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_teql: fix lockdep splat
Date: Wed, 30 Nov 2011 17:11:23 -0500 (EST)
Message-ID: <20111130.171123.204582942671431753.davem@davemloft.net>
References: <1322662138.2403.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55962 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751664Ab1K3WL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 17:11:26 -0500
In-Reply-To: <1322662138.2403.25.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2011 15:08:58 +0100

> We need rcu_read_lock() protection before using dst_get_neighbour(), and
> we must cache its value (pass it to __teql_resolve())
> 
> teql_master_xmit() is called under rcu_read_lock_bh() protection, its
> not enough.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
