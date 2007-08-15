From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Thu, 16 Aug 2007 07:41:46 +0800
Message-ID: <20070815234146.GB28775@gondor.apana.org.au>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in> <46C2D6F3.3070707@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151713080.16414@enigma.security.iitk.ac.in> <46C2FADB.7020407@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151906330.16414@enigma.security.iitk.ac.in> <20070815142516.GB9645@linux.vnet.ibm.com> <4413.1187201997@redhat.com> <20070815184520.GG9645@linux.vnet.ibm.com>
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
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4903 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S964981AbXHOXmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 19:42:16 -0400
Content-Disposition: inline
In-Reply-To: <20070815184520.GG9645@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 15, 2007 at 11:45:20AM -0700, Paul E. McKenney wrote:
> On Wed, Aug 15, 2007 at 07:19:57PM +0100, David Howells wrote:
> > Herbert Xu <herbert@gondor.apana.org.au> wrote:
> > 
> > > Let's turn this around.  Can you give a single example where
> > > the volatile semantics is needed in a legitimate way?
> > 
> > Accessing H/W registers?  But apart from that...
> 
> Communicating between process context and interrupt/NMI handlers using
> per-CPU variables.

Remeber we're talking about atomic_read/atomic_set.  Please
cite the actual file/function name you have in mind.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
