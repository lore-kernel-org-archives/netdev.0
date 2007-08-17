From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Fri, 17 Aug 2007 09:28:00 +0800
Message-ID: <20070817012800.GA12621@gondor.apana.org.au>
References: <alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi> <46C4ABA5.9010804@redhat.com> <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com> <20070817010232.GK16957@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Paul Mackerras <paulus@samba.org>,
	Satyam Sharma <satyam@infradead.org>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3978 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755229AbXHQB3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 21:29:13 -0400
Content-Disposition: inline
In-Reply-To: <20070817010232.GK16957@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 06:02:32PM -0700, Paul E. McKenney wrote:
> 
> Yep.  Or you can use atomic_dec_return() instead of using a barrier.

Or you could use smp_mb__{before,after}_atomic_dec.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
