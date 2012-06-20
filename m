From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ipv4: Early TCP socket demux.
Date: Tue, 19 Jun 2012 23:14:12 -0700 (PDT)
Message-ID: <20120619.231412.1236237191660427779.davem@davemloft.net>
References: <20120619193549.13bcffa7@s6510.linuxnetplumber.net>
	<20120619.214657.1345825814176201681.davem@davemloft.net>
	<1340171940.4604.799.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34343 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab2FTGON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2012 02:14:13 -0400
In-Reply-To: <1340171940.4604.799.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Jun 2012 07:59:00 +0200

> On Tue, 2012-06-19 at 21:46 -0700, David Miller wrote:
> 
>> These numbers can be decreased further, because since we're already
>> looking at the TCP header we can pre-cook the TCP control block in the
>> SKB and skip much of the stuff that tcp_v4_rcv() does since we've done
>> it already in the early demux code.
> 
> It could be done at GRO level and remove one another demux.
> 
> As routers probably have no use of GRO, no need of additional knob.

That's a great idea.
