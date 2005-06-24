From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] dst_entry structure use,lastuse and refcnt abstraction
Date: Thu, 23 Jun 2005 23:16:55 -0700 (PDT)
Message-ID: <20050623.231655.68159153.davem@davemloft.net>
References: <Pine.LNX.4.62.0506232057340.29222@graphe.net>
	<20050623.211140.131918815.davem@davemloft.net>
	<Pine.LNX.4.62.0506232256360.17993@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	shai@scalex86.org, akpm@osdl.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: clameter@engr.sgi.com
In-Reply-To: <Pine.LNX.4.62.0506232256360.17993@schroedinger.engr.sgi.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <clameter@engr.sgi.com>
Date: Thu, 23 Jun 2005 23:03:45 -0700 (PDT)

> Ok. Then we are done. With 58 Itanium processors and 200G Ram I get 
> more than 10% improvement ;-). With 500 tasks we have 453 vs. 499 j/m/t.
> That is 9.21%. For 300 tasks we have 9.4% etc. I am sure that I can push 
> this some more with bigger counts of processors and also some other NUMA 
> related performance issues.

So it took 7 times more processors to increase the performance gain by
just over 3 on a microscopic synthetic benchmark.  That's not
impressive at all.

And you still haven't shown what happens for the workloads I
suggested.  A web benchmark, with say a thousand unique clients, would
be sufficient for one of those btw.  That case has very low dst
locality, yet dsts are useful because you'll have about 2 or 3
concurrent connections per dst.
