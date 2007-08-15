From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Wed, 15 Aug 2007 12:35:31 +0200
Message-ID: <46C2D6F3.3070707@s5r6.in-berlin.de>
References: <20070809131423.GA9927@shell.boston.redhat.com> <Pine.LNX.4.64.0708141529310.32693@schroedinger.engr.sgi.com> <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <clameter@sgi.com>,
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
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hp3.statik.tu-cottbus.de ([141.43.120.68]:37731 "EHLO
	hp3.statik.tu-cottbus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634AbXHOKfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 06:35:33 -0400
In-Reply-To: <alpine.LFD.0.999.0708150417240.6482@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Satyam Sharma wrote:
> [ BTW, why do we want the compiler to not optimize atomic_read()'s in
>   the first place? Atomic ops guarantee atomicity, which has nothing
>   to do with "volatility" -- users that expect "volatility" from
>   atomic ops are the ones who must be fixed instead, IMHO. ]

LDD3 says on page 125:  "The following operations are defined for the
type [atomic_t] and are guaranteed to be atomic with respect to all
processors of an SMP computer."

Doesn't "atomic WRT all processors" require volatility?
-- 
Stefan Richter
-=====-=-=== =--- -====
http://arcgraph.de/sr/
