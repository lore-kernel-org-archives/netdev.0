From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH 2/3] net: fix enforcing of fragment queue hash
 list depth
Date: Wed, 24 Apr 2013 15:35:23 +0200
Message-ID: <1366810523.26911.495.camel@localhost>
References: <20130418213637.14296.43143.stgit@dragon>
	 <20130418213732.14296.36026.stgit@dragon>
	 <1366366287.3205.98.camel@edumazet-glaptop>
	 <1366373950.26911.134.camel@localhost>
	 <1366382991.16391.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034Ab3DXNfa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 09:35:30 -0400
In-Reply-To: <1366382991.16391.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-19 at 07:49 -0700, Eric Dumazet wrote:
> On Fri, 2013-04-19 at 14:19 +0200, Jesper Dangaard Brouer wrote:
> 
> > When removing the LRU system (which is the real bottleneck, see perf
> > tests in cover mail), and doing direct hash cleaning we are trading-in
> > accuracy.
[...]
> > The reason I don't want a too big hash table is the following.
> > 
> > Worst case 1024 buckets * 130K bytes = 133 MBytes, which on smaller
> > embedded systems is a lot of kernel memory we are permitting a remote
> > host to "lock-down".
> 
> Thats pretty irrelevant, memory is limited by the total amount of memory
> used by fragments, not by hash table size.
>
> Its called /proc/sys/net/ipv4/ipfrag_high_thresh


I was talking about patch-03, where I do "direct hash cleaning", and
have moved the mem limit "ipfrag_high_thresh" into the hash cleaning
step.

It seems we are talking past each-other...

--Jesper
