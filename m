From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 16:53:35 -0700
Message-ID: <20070815235335.GU9645@linux.vnet.ibm.com>
References: <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in> <20070815142516.GB9645@linux.vnet.ibm.com> <4413.1187201997@redhat.com> <20070815184520.GG9645@linux.vnet.ibm.com> <20070815234146.GB28775@gondor.apana.org.au>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Howells <dhowells@redhat.com>,
	Satyam Sharma <satyam@infradead.org>,
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
To: Herbert Xu <herbert.xu@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57683 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762660AbXHOXxj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 19:53:39 -0400
Content-Disposition: inline
In-Reply-To: <20070815234146.GB28775@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 07:41:46AM +0800, Herbert Xu wrote:
> On Wed, Aug 15, 2007 at 11:45:20AM -0700, Paul E. McKenney wrote:
> > On Wed, Aug 15, 2007 at 07:19:57PM +0100, David Howells wrote:
> > > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > > 
> > > > Let's turn this around.  Can you give a single example where
> > > > the volatile semantics is needed in a legitimate way?
> > > 
> > > Accessing H/W registers?  But apart from that...
> > 
> > Communicating between process context and interrupt/NMI handlers using
> > per-CPU variables.
> 
> Remeber we're talking about atomic_read/atomic_set.  Please
> cite the actual file/function name you have in mind.

Yep, we are indeed talking about atomic_read()/atomic_set().

We have been through this issue already in this thread.

							Thanx, Paul
