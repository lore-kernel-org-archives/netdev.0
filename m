From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] codel: refine one condition to avoid a nul rec_inv_sqrt
Date: Mon, 30 Jul 2012 14:54:12 -0700 (PDT)
Message-ID: <20120730.145412.1689803770003231369.davem@davemloft.net>
References: <1343631141.2626.13293.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lp2s1h@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58882 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754633Ab2G3VyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 17:54:13 -0400
In-Reply-To: <1343631141.2626.13293.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 30 Jul 2012 08:52:21 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> One condition before codel_Newton_step() was not good if
> we never left the dropping state for a flow. As a result
> rec_inv_sqrt was 0, instead of the ~0 initial value.
> 
> codel control law was then set to a very aggressive mode, dropping
> many packets before reaching 'target' and recovering from this problem.
> 
> To keep codel_vars_init() as efficient as possible, refine
> the condition to make sure rec_inv_sqrt initial value is correct
> 
> Many thanks to Anton Mich for discovering the issue and suggesting
> a fix.
> 
> Reported-by: Anton Mich <lp2s1h@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
