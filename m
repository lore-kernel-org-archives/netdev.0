From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] i386: Fix a couple busy loops in mach_wakecpu.h:wait_for_init_deassert()
Date: Fri, 24 Aug 2007 10:06:29 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708241005360.20501@schroedinger.engr.sgi.com>
References: <46C2350A.1010807@redhat.com> <20070815081841.GA16551@osiris.boeblingen.de.ibm.com>
 <alpine.LFD.0.999.0708160606580.24380@enigma.security.iitk.ac.in>
 <200708241259.33659.vda.linux@googlemail.com>
 <alpine.LFD.0.999.0708241812110.20322@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Denys Vlasenko <vda.linux@googlemail.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, davem@davemloft.net, schwidefsky@de.ibm.com,
	wensong@linux-vs.org, horms@verge.net.au, wjiang@resilience.com,
	cfriesen@nortel.com, zlynx@acm.org, rpjday@mindspring.com,
	jesper.juhl@gmail.com, segher@kernel.crashing.org,
	Nick Piggin <nickpiggin@yahoo.com.au>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]:49283 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751715AbXHXRGd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2007 13:06:33 -0400
In-Reply-To: <alpine.LFD.0.999.0708241812110.20322@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Aug 2007, Satyam Sharma wrote:

> But if people do seem to have a mixed / confused notion of atomicity
> and barriers, and if there's consensus, then as I'd said earlier, I
> have no issues in going with the consensus (eg. having API variants).
> Linus would be more difficult to convince, however, I suspect :-)

The confusion may be the result of us having barrier semantics in 
atomic_read. If we take that out then we may avoid future confusions.

