From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net_sched: sfq: fix mem alloc error
 recovery
Date: Wed, 04 Jan 2012 14:13:01 -0500 (EST)
Message-ID: <20120104.141301.1584452659395659449.davem@davemloft.net>
References: <1325694144.2428.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751502Ab2ADTNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2012 14:13:04 -0500
In-Reply-To: <1325694144.2428.30.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Jan 2012 17:22:24 +0100

> Since commit 817fb15dfd98 (net_sched: sfq: allow divisor to be a
> parameter), we can leave perturbation timer armed if a memory allocation
> error aborts sfq_init().
> 
> Memory containing active struct timer_list is freed and kernel can
> crash.
> 
> Call sfq_destroy() from sfq_init() to properly dismantle qdisc.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
