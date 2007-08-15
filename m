From: Satyam Sharma <satyam@infradead.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 22:48:28 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0708152244310.16414@enigma.security.iitk.ac.in>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in>
 <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in>
 <20070815142516.GB9645@linux.vnet.ibm.com> <20070815153335.GA23593@gondor.apana.org.au>
 <20070815160830.GC9645@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60392 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759535AbXHORF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 13:05:59 -0400
In-Reply-To: <20070815160830.GC9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Wed, 15 Aug 2007, Paul E. McKenney wrote:

> On Wed, Aug 15, 2007 at 11:33:36PM +0800, Herbert Xu wrote:
> > On Wed, Aug 15, 2007 at 07:25:16AM -0700, Paul E. McKenney wrote:
> > > 
> > > Do we really need another set of APIs?  Can you give even one example
> > > where the pre-existing volatile semantics are causing enough of a problem
> > > to justify adding yet more atomic_*() APIs?
> > 
> > Let's turn this around.  Can you give a single example where
> > the volatile semantics is needed in a legitimate way?
> 
> Sorry, but you are the one advocating for the change.

Not for i386 and x86_64 -- those have atomic ops without any "volatile"
semantics (currently as per existing definitions).
