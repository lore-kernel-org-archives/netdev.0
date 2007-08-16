From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Wed, 15 Aug 2007 17:23:10 -0700
Message-ID: <20070816002310.GW9645@linux.vnet.ibm.com>
References: <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in> <20070815142516.GB9645@linux.vnet.ibm.com> <4413.1187201997@redhat.com> <20070815184520.GG9645@linux.vnet.ibm.com> <20070815234146.GB28775@gondor.apana.org.au> <20070815235335.GU9645@linux.vnet.ibm.com> <20070816001248.GA29214@gondor.apana.org.au>
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
Received: from e1.ny.us.ibm.com ([32.97.182.141]:41912 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751117AbXHPAXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Aug 2007 20:23:14 -0400
Content-Disposition: inline
In-Reply-To: <20070816001248.GA29214@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 08:12:48AM +0800, Herbert Xu wrote:
> On Wed, Aug 15, 2007 at 04:53:35PM -0700, Paul E. McKenney wrote:
> >
> > > > Communicating between process context and interrupt/NMI handlers using
> > > > per-CPU variables.
> > > 
> > > Remeber we're talking about atomic_read/atomic_set.  Please
> > > cite the actual file/function name you have in mind.
> > 
> > Yep, we are indeed talking about atomic_read()/atomic_set().
> > 
> > We have been through this issue already in this thread.
> 
> Sorry, but I must've missed it.  Could you cite the file or
> function for my benefit?

I might summarize the thread if there is interest, but I am not able to
do so right this minute.

						Thanx, Paul
