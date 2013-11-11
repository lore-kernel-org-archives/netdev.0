From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: protect for_each_sk_fl_rcu in mem_check with
 rcu_read_lock_bh
Date: Mon, 11 Nov 2013 01:26:44 -0500 (EST)
Message-ID: <20131111.012644.913394905871739133.davem@davemloft.net>
References: <20131108182621.GA404@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, florent.fourcot@enst-bretagne.fr
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab3KKG0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 01:26:48 -0500
In-Reply-To: <20131108182621.GA404@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 8 Nov 2013 19:26:21 +0100

> Fixes a suspicious rcu derference warning.
> 
> Cc: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good, applied and queued up for -stable.
