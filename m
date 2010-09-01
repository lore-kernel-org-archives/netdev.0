From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC PATCH net-next-2.6] gro: drivers should feed GRO only with
 TCP packets
Date: Wed, 1 Sep 2010 10:55:19 -0700
Message-ID: <20100901105519.603492cf@nehalam>
References: <1283360686.2556.381.camel@edumazet-laptop>
	<20100901104235.5476a242@nehalam>
	<20100901.104805.35816252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36323 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755396Ab0IARzV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 13:55:21 -0400
In-Reply-To: <20100901.104805.35816252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 01 Sep 2010 10:48:05 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Wed, 1 Sep 2010 10:42:35 -0700
> 
> > There was talk of doing GRO for UDP as well but it never
> > got implemented. 
> 
> I suppose the most direct application would be for IP fragmentation.
> 
> In fact I could see that working very well.
> 
> But for non-fragmented UDP... I can't see much value to that.
> 
> We'd have to preserve the packet boundaries, and process each chunk of
> data as one packet at a time within those boundaries, to retain
> datagram recvmsg() semantics.

I was thinking for fragmented UDP, which still unfortunately
gets used. 
