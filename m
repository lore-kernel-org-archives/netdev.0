From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not leak non zero tstamp in output
 packets
Date: Fri, 07 Mar 2014 14:33:22 -0500 (EST)
Message-ID: <20140307.143322.1145797644639586688.davem@davemloft.net>
References: <1394057318.27473.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaCGTdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 14:33:24 -0500
In-Reply-To: <1394057318.27473.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 05 Mar 2014 14:08:38 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Usage of skb->tstamp should remain private to TCP stack
> (only set on packets on write queue, not on cloned ones)
> 
> Otherwise, packets given to loopback interface with a non null tstamp
> can confuse netif_rx() / net_timestamp_check()
> 
> Other possibility would be to clear tstamp in loopback_xmit(),
> as done in skb_scrub_packet()
> 
> Fixes: 740b0f1841f6 ("tcp: switch rtt estimations to usec resolution")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Willem de Bruijn <willemb@google.com>

Applied, thanks Eric.
