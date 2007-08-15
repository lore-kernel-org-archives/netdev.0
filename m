From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 12:59:01 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0708151258340.7326@schroedinger.engr.sgi.com>
References: <20070809131423.GA9927@shell.boston.redhat.com>
 <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com>
 <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
 <46C2D6F3.3070707@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Satyam Sharma <satyam@infradead.org>,
	Chris Snook <csnook@redhat.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, torvalds@linux-foundation.org,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
	ak@suse.de, heiko.carstens@de.ibm.com, davem@davemloft.net,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936198AbXHOT7e@vger.kernel.org>
In-Reply-To: <46C2D6F3.3070707@s5r6.in-berlin.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Aug 2007, Stefan Richter wrote:

> LDD3 says on page 125:  "The following operations are defined for the
> type [atomic_t] and are guaranteed to be atomic with respect to all
> processors of an SMP computer."
> 
> Doesn't "atomic WRT all processors" require volatility?

Atomic operations only require exclusive access to the cacheline while the 
value is modified.
