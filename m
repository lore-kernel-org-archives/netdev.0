From: Christoph Lameter <christoph@lameter.com>
Subject: Re: [PATCH] dst_entry structure use,lastuse and refcnt abstraction
Date: Thu, 23 Jun 2005 21:06:30 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0506232057340.29222@graphe.net>
References: <Pine.LNX.4.62.0506232037430.28814@graphe.net>
 <20050623.204702.26274560.davem@davemloft.net> <Pine.LNX.4.62.0506232047450.29103@graphe.net>
 <20050623.205447.66178303.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	shai@scalex86.org, akpm@osdl.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050623.205447.66178303.davem@davemloft.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 23 Jun 2005, David S. Miller wrote:

> Ok.  You're going to have to come up with something better
> than a %3 AIM benchmark increase with 5000 threads to justify
> those invasive NUMA changes, and thus this infrastructure for
> it.

I am sure one can do better than that. The x445 is the smallest NUMA box 
that I know of and the only one available in the context of that project. 
But I am also not sure that this will reach proportions  that will 
outweigh the complexity added by these patches. What would be 
the performance benefit that we would need to see to feel that is 
is right to get such a change in?

> I'm picking those examples, because I am rather certain your patches
> will hurt performance in those cases.  The data structure size
> expansion and extra memory allocations alone for the per-node dst
> stuff should be good about doing that.

Hmm. I like the idea of a separate routing cache per node. May actually 
reach higher performance than splitting the counters. Lets think a bit 
about that.
