From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: reflect SYN queue_mapping into SYNACK packets
Date: Fri, 01 Jun 2012 14:23:25 -0400 (EDT)
Message-ID: <20120601.142325.1372147261206298305.davem@davemloft.net>
References: <1338551270.2760.1505.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ncardwell@google.com, brouer@redhat.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932813Ab2FASX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 14:23:27 -0400
In-Reply-To: <1338551270.2760.1505.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 01 Jun 2012 13:47:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> While testing how linux behaves on SYNFLOOD attack on multiqueue device
> (ixgbe), I found that SYNACK messages were dropped at Qdisc level
> because we send them all on a single queue.
> 
> Obvious choice is to reflect incoming SYN packet @queue_mapping to
> SYNACK packet.
> 
> Under stress, my machine could only send 25.000 SYNACK per second (for
> 200.000 incoming SYN per second). NIC : ixgbe with 16 rx/tx queues.
> 
> After patch, not a single SYNACK is dropped.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
