From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: ECN blackhole should not force quickack mode
Date: Tue, 27 Sep 2011 00:59:05 -0400 (EDT)
Message-ID: <20110927.005905.1166544891922183065.davem@davemloft.net>
References: <1316757739.2560.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hkchu@google.com,
	ilpo.jarvinen@helsinki.fi, jhs@mojatatu.com, jg@freedesktop.org,
	dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42083 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751585Ab1I0E7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 00:59:21 -0400
In-Reply-To: <1316757739.2560.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 23 Sep 2011 08:02:19 +0200

> While playing with a new ADSL box at home, I discovered that ECN
> blackhole can trigger suboptimal quickack mode on linux : We send one
> ACK for each incoming data frame, without any delay and eventual
> piggyback.
> 
> This is because TCP_ECN_check_ce() considers that if no ECT is seen on a
> segment, this is because this segment was a retransmit.
> 
> Refine this heuristic and apply it only if we seen ECT in a previous
> segment, to detect ECN blackhole at IP level.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied to net-next, thanks Eric.
