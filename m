From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Sat, 18 Aug 2007 20:12:48 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708180533100.3666@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <20070815233721.91032366.billfink@mindspring.com>
 <alpine.LFD.0.999.0708161045360.25951@enigma.security.iitk.ac.in>
 <alpine.LFD.0.999.0708161115370.25951@enigma.security.iitk.ac.in>
 <43eccf425e36943ce0411c3b504b1de2@kernel.crashing.org>
 <alpine.LFD.0.999.0708170957350.3666@enigma.security.iitk.ac.in>
 <d14d1a768bfbbef34ee9f981cfd348c6@kernel.crashing.org>
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
	wensong@linux-vs.org, wjiang@resilience.com
To: Segher Boessenkool <segher@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46995 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753270AbXHROaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2007 10:30:20 -0400
In-Reply-To: <d14d1a768bfbbef34ee9f981cfd348c6@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 18 Aug 2007, Segher Boessenkool wrote:

> > > GCC manual, section 6.1, "When
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > > is a Volatile Object Accessed?" doesn't say anything of the
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> > > kind.
      ^^^^^

> > True, "implementation-defined" as per the C standard _is_ supposed to mean
    ^^^^^

> > "unspecified behaviour where each implementation documents how the choice
> > is made". So ok, probably GCC isn't "documenting" this
                              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^

> > implementation-defined behaviour which it is supposed to, but can't really
> > fault them much for this, probably.
> 
> GCC _is_ documenting this, namely in this section 6.1.

(Again totally petty, but) Yes, but ...

> It doesn't
  ^^^^^^^^^^
> mention volatile-casted stuff.  Draw your own conclusions.
  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

... exactly. So that's why I said "GCC isn't documenting _this_".

Man, try _reading_ mails before replying to them ...
