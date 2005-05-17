From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Tue, 17 May 2005 15:12:39 -0700 (PDT)
Message-ID: <20050517.151239.74747463.davem@davemloft.net>
References: <20050517202730.GA79960@muc.de>
	<20050517.140245.71090021.davem@davemloft.net>
	<428A613F.1020303@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: rick.jones2@hp.com
In-Reply-To: <428A613F.1020303@hp.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Rick Jones <rick.jones2@hp.com>
Date: Tue, 17 May 2005 14:25:19 -0700

> just how much extra overhead would there be to track the interarrival time of ip 
> datagram fragments and would that allow someone to make a guess as to how long 
> to reasonably wait for all the fragments to arrive? (or did I miss that being 
> shot-down already?)

I spam you with fragments tightly interspaced matching a known
shost/dhost/ID tuple, lowering your interarrival estimate.  The
legitimate fragment source can thus never get his fragments in
before the timer expires.

Every other one of these IP fragmentation ideas tends to have
some DoS hole in it.
