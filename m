From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 16:51:25 -0700
Message-ID: <20070815235125.GT9645@linux.vnet.ibm.com>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com> <20070815234021.GA28775@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Snook <csnook@redhat.com>, satyam@infradead.org,
	clameter@sgi.com, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org, ak@suse.de,
	heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:45932 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757973AbXHOXv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 19:51:29 -0400
Content-Disposition: inline
In-Reply-To: <20070815234021.GA28775@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 07:40:21AM +0800, Herbert Xu wrote:
> On Wed, Aug 15, 2007 at 12:13:12PM -0400, Chris Snook wrote:
> >
> > Part of the motivation here is to fix heisenbugs.  If I knew where they 
> 
> By the same token we should probably disable optimisations
> altogether since that too can create heisenbugs.

Precisely the point -- use of volatile (whether in casts or on asms)
in these cases are intended to disable those optimizations likely to
result in heisenbugs.  But they are also intended to leave other
valuable optimizations in force.

						Thanx, Paul
