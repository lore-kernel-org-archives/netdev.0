From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 09:54:50 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708170945300.3666@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <20070815233721.91032366.billfink@mindspring.com>
 <alpine.LFD.0.999.0708161045360.25951@enigma.security.iitk.ac.in>
 <4952d3f536060c186f40c277dfc74194@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>, heiko.carstens@de.ibm.com,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Bill Fink <billfink@mindspring.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, ak@suse.de, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com, davids@webmaster.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:55646 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751434AbXHQEM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 00:12:26 -0400
In-Reply-To: <4952d3f536060c186f40c277dfc74194@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 16 Aug 2007, Segher Boessenkool wrote:

> > Note that "volatile"
> > is a type-qualifier, not a type itself, so a cast of the _object_ itself
> > to a qualified-type i.e. (volatile int) would not make the access itself
> > volatile-qualified.
> 
> There is no such thing as "volatile-qualified access" defined
> anywhere; there only is the concept of a "volatile-qualified
> *object*".

Sure, "volatile-qualified access" was not some standard term I used
there. Just something to mean "an access that would make the compiler
treat the object at that memory as if it were an object with a
volatile-qualified type".

Now the second wording *IS* technically correct, but come on, it's
24 words long whereas the original one was 3 -- and hopefully anybody
reading the shorter phrase *would* have known anyway what was meant,
without having to be pedantic about it :-)


Satyam
