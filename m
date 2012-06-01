From: Hans Schillstrom <hans.schillstrom@ericsson.com>
Subject: Re: [PATCH] tcp: reflect SYN queue_mapping into SYNACK packets
Date: Fri, 1 Jun 2012 12:45:16 +0200
Message-ID: <201206011248.26748.hans.schillstrom@ericsson.com>
References: <1338544881.2760.1502.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw7.ericsson.se ([193.180.251.48]:49858 "EHLO
	mailgw7.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758920Ab2FAKsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 06:48:31 -0400
In-Reply-To: <1338544881.2760.1502.camel@edumazet-glaptop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 01 June 2012 12:01:21 Eric Dumazet wrote:
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
Great, that was just what I was looking for
Will try to get this on into test to day.

IPv6, do you add that as well ?

-- 
Regards
Hans Schillstrom
