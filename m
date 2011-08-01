From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip6tnl: avoid touching dst refcount in ip6_tnl_xmit2()
Date: Mon, 01 Aug 2011 01:56:06 -0700 (PDT)
Message-ID: <20110801.015606.1882260753384583237.davem@davemloft.net>
References: <1311863545.2346.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39686 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874Ab1HAI4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 04:56:08 -0400
In-Reply-To: <1311863545.2346.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 28 Jul 2011 16:32:25 +0200

> Even using percpu stats, we still hit tunnel dst_entry refcount in
> ip6_tnl_xmit2()
> 
> Since we are in RCU locked section, we can use skb_dst_set_noref() and
> avoid these atomic operations, leaving dst shared on cpus.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Queued up for net-next
