From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Tue, 21 Aug 2007 00:07:15 +0200
Message-ID: <f95b4ab810e3850f92ee7e98a1219bb2@kernel.crashing.org>
References: <18117.6495.397597.582736@cargo.ozlabs.ibm.com> <20070817035342.GA14744@gondor.apana.org.au> <alpine.LFD.0.999.0708171142550.3666@enigma.security.iitk.ac.in> <46C55E90.7010407@yahoo.com.au> <alpine.LFD.0.999.0708171431150.3666@enigma.security.iitk.ac.in> <46C56ADF.8010501@cyberone.com.au> <alpine.LFD.0.999.0708171612440.3666@enigma.security.iitk.ac.in> <46C59717.4020108@cyberone.com.au> <alpine.LFD.0.999.0708170929580.30176@woody.linux-foundation.org> <46C993DF.4080400@redhat.com> <20070820133207.GA13835@gondor.apana.org.au> <46C99945.9080303@redhat.com>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	Stefan Richter <stefanr@s5r6.in-berlin.de>, horms@verge.net.au,
	Satyam Sharma <satyam@infradead.org>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	Netdev <netdev@vger.kernel.org>, cfriesen@nortel.com,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Herbert Xu <herbert.xu@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, Nick Piggin <piggin@cyberone.com.au>,
	wjiang@resilience.com
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:40720 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759810AbXHTWOg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2007 18:14:36 -0400
In-Reply-To: <46C99945.9080303@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Such code generally doesn't care precisely when it gets the update, 
> just that the update is atomic, and it doesn't loop forever.

Yes, it _does_ care that it gets the update _at all_, and preferably
as early as possible.

> Regardless, I'm convinced we just need to do it all in assembly.

So do you want "volatile asm" or "plain asm", for atomic_read()?
The asm version has two ways to go about it too...


Segher

