From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 15:42:33 -0700
Message-ID: <20070815224233.GP9645@linux.vnet.ibm.com>
References: <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in> <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de> <20070815162722.GD9645@linux.vnet.ibm.com> <d4406222873856f472b9173a14a19aa2@kernel.crashing.org> <20070815185724.GH9645@linux.vnet.ibm.com> <alpine.LFD.0.999.0708160118330.16414@enigma.security.iitk.ac.in> <20070815201748.GN9645@linux.vnet.ibm.com> <96f3fa3929d873263891fefadb222431@kernel.crashing.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, netdev@vger.kernel.org, ak@suse.de,
	cfriesen@nortel.com, Heiko Carstens <heiko.carstens@de.ibm.com>,
	jesper.juhl@gmail.com, linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:46531 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937113AbXHOWmj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 18:42:39 -0400
Content-Disposition: inline
In-Reply-To: <96f3fa3929d873263891fefadb222431@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 10:52:53PM +0200, Segher Boessenkool wrote:
> >>I think this was just terminology confusion here again. Isn't "any 
> >>code
> >>that it cannot currently see" the same as "another compilation unit",
> >>and wouldn't the "compilation unit" itself expand if we ask gcc to
> >>compile more than one unit at once? Or is there some more specific
> >>"definition" for "compilation unit" (in gcc lingo, possibly?)
> >
> >This is indeed my understanding -- "compilation unit" is whatever the
> >compiler looks at in one go.  I have heard the word "module" used for
> >the minimal compilation unit covering a single .c file and everything
> >that it #includes, but there might be a better name for this.
> 
> Yes, that's what's called "compilation unit" :-)
> 
> [/me double checks]
> 
> Erm, the C standard actually calls it "translation unit".
> 
> To be exact, to avoid any more confusion:
> 
> 5.1.1.1/1:
> A C program need not all be translated at the same time. The
> text of the program is kept in units called source files, (or
> preprocessing files) in this International Standard. A source
> file together with all the headers and source files included
> via the preprocessing directive #include is known as a
> preprocessing translation unit. After preprocessing, a
> preprocessing translation unit is called a translation unit.

I am OK with "translation" and "compilation" being near-synonyms.  ;-)

						Thanx, Paul
