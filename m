From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_sfq: revert dont put new flow at the end of flows
Date: Fri, 16 Mar 2012 01:56:25 -0700 (PDT)
Message-ID: <20120316.015625.2065025946513016046.davem@davemloft.net>
References: <1327570722.8191.46.camel@probook>
	<1331697865.2456.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, dave.taht@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36335 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031800Ab2CPI4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 04:56:32 -0400
In-Reply-To: <1331697865.2456.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Mar 2012 21:04:25 -0700

> This reverts commit d47a0ac7b6 (sch_sfq: dont put new flow at the end of
> flows)
> 
> As Jesper found out, patch sounded great but has bad side effects.
> 
> In stress situation, pushing new flows in front of the queue can prevent
> old flows doing any progress. Packets can stay in SFQ queue for
> unlimited amount of time.
> 
> It's possible to add heuristics to limit this problem, but this would
> add complexity outside of SFQ scope.
> 
> A more sensible answer to Dave Taht concerns (who reported the issued I
> tried to solve in original commit) is probably to use a qdisc hierarchy
> so that high prio packets dont enter a potentially crowded SFQ qdisc.
> 
> Reported-by: Jesper Dangaard Brouer <jdb@comx.dk>
> Cc: Dave Taht <dave.taht@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
