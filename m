From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: enable per-socket rate limiting of all
 'challenge acks'
Date: Fri, 15 Jul 2016 14:18:42 -0700 (PDT)
Message-ID: <20160715.141842.54072741247152503.davem@davemloft.net>
References: <1468510720-322-1-git-send-email-jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org, ncardwell@google.com,
	ycheng@google.com, ycao009@ucr.edu
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbcGOVSn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 17:18:43 -0400
In-Reply-To: <1468510720-322-1-git-send-email-jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Thu, 14 Jul 2016 11:38:40 -0400

> From: Jason Baron <jbaron@akamai.com>
> 
> The per-socket rate limit for 'challenge acks' was introduced in the
> context of limiting ack loops:
> 
> commit f2b2c582e824 ("tcp: mitigate ACK loops for connections as tcp_sock")
> 
> And I think it can be extended to rate limit all 'challenge acks' on a
> per-socket basis.
> 
> Since we have the global tcp_challenge_ack_limit, this patch allows for
> tcp_challenge_ack_limit to be set to a large value and effectively rely on
> the per-socket limit, or set tcp_challenge_ack_limit to a lower value and
> still prevents a single connections from consuming the entire challenge ack
> quota.
> 
> It further moves in the direction of eliminating the global limit at some
> point, as Eric Dumazet has suggested. This a follow-up to:
> Subject: tcp: make challenge acks less predictable
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>
> Cc: Yue Cao <ycao009@ucr.edu>
> Signed-off-by: Jason Baron <jbaron@akamai.com>

Applied, thanks.
