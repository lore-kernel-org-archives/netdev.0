From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 23:00:30 +0200
Message-ID: <43eccf425e36943ce0411c3b504b1de2@kernel.crashing.org>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <20070815233721.91032366.billfink@mindspring.com> <alpine.LFD.0.999.0708161045360.25951@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708161115370.25951@enigma.security.iitk.ac.in>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:47902 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbXHPVCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 17:02:16 -0400
In-Reply-To: <alpine.LFD.0.999.0708161115370.25951@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Here, I should obviously admit that the semantics of *(volatile int *)&
> aren't any neater or well-defined in the _language standard_ at all. 
> The
> standard does say (verbatim) "precisely what constitutes as access to
> object of volatile-qualified type is implementation-defined", but GCC
> does help us out here by doing the right thing.

Where do you get that idea?  GCC manual, section 6.1, "When
is a Volatile Object Accessed?" doesn't say anything of the
kind.  PR33053 and some others.

> Honestly, given such confusion, and the propensity of the "volatile"
> type-qualifier keyword to be ill-defined (or at least poorly 
> understood,
> often inconsistently implemented), I'd (again) express my opinion that 
> it
> would be best to avoid its usage, given other alternatives do exist.

Yeah.  Or we can have an email thread like this every time
someone proposes a patch that uses an atomic variable ;-)


Segher

