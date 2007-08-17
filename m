From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 13:16:00 +1000
Message-ID: <18117.4848.695269.72976@cargo.ozlabs.ibm.com>
References: <E1ILCgh-00052A-00@gondolin.me.apana.org.au>
	<46C32618.2080108@redhat.com>
	<20070815234021.GA28775@gondor.apana.org.au>
	<3694fb2e4ed1e4d9bf873c0d050c911e@kernel.crashing.org>
	<46C3B50E.7010702@yahoo.com.au>
	<194369f4c96ea0e24decf8f9197d5bad@kernel.crashing.org>
	<46C505B2.6030704@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	heiko.carstens@de.ibm.com, horms@verge.net.au,
	linux-kernel@vger.kernel.org, rpjday@mindspring.com, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org, zlynx@acm.org,
	satyam@infradead.org, clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert.xu@redhat.com>, davem@davemloft.net,
	wensong@linux-vs.org, wjiang@resilience.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:56866 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751009AbXHQDQJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 23:16:09 -0400
In-Reply-To: <46C505B2.6030704@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Nick Piggin writes:

> So i386 and x86-64 don't have volatiles there, and it saves them a
> few K of kernel text. What you need to justify is why it is a good

I'm really surprised it's as much as a few K.  I tried it on powerpc
and it only saved 40 bytes (10 instructions) for a G5 config.

Paul.
