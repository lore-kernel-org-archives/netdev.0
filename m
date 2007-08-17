From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 15:53:02 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708171547050.3666@enigma.security.iitk.ac.in>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au> <46C32618.2080108@redhat.com>
 <20070815234021.GA28775@gondor.apana.org.au> <3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
 <46C3B50E.7010702@yahoo.com.au> <194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
 <46C505B2.6030704@yahoo.com.au> <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
 <alpine.LFD.0.999.0708162033400.30176@woody.linux-foundation.org>
 <alpine.LFD.0.999.0708171016160.3666@enigma.security.iitk.ac.in>
 <46C54D94.5080803@yahoo.com.au> <alpine.LFD.0.999.0708171358520.3666@enigma.security.iitk.ac.in>
 <18117.28409.943948.355586@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Nick Piggin <nickpiggin@yahoo.com.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, ak@suse.de, netdev@vger.kernel.org,
	cfriesen@nortel.com, Andrew Morton <akpm@linux-foundation.org>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:33357 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755751AbXHQKK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 06:10:28 -0400
In-Reply-To: <18117.28409.943948.355586@cargo.ozlabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Fri, 17 Aug 2007, Paul Mackerras wrote:

> Satyam Sharma writes:
> 
> > I wonder if this'll generate smaller and better code than _both_ the
> > other atomic_read_volatile() variants. Would need to build allyesconfig
> > on lots of diff arch's etc to test the theory though.
> 
> I'm sure it would be a tiny effect.
> 
> This whole thread is arguing about effects that are quite
> insignificant.

Hmm, the fact that this thread became what it did, probably means that
most developers on this list do not mind thinking/arguing about effects
or optimizations that are otherwise "tiny". But yeah, they are tiny
nonetheless.
