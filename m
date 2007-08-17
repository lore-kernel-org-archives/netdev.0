From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all
 architectures
Date: Fri, 17 Aug 2007 12:16:39 +1000
Message-ID: <18117.1287.779351.836552@cargo.ozlabs.ibm.com>
References: <20070816003948.GY9645@linux.vnet.ibm.com>
	<Pine.LNX.4.64.0708151740570.10497@schroedinger.engr.sgi.com>
	<18115.44462.622801.683446@cargo.ozlabs.ibm.com>
	<20070816020042.GA30650@gondor.apana.org.au>
	<18115.45316.702491.681906@cargo.ozlabs.ibm.com>
	<alpine.LFD.0.999.0708160800130.24380@enigma.security.iitk.ac.in>
	<alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in>
	<18115.52863.638655.658466@cargo.ozlabs.ibm.com>
	<20070816053945.GB32442@gondor.apana.org.au>
	<18115.62741.807704.969977@cargo.ozlabs.ibm.com>
	<20070816070907.GA964@gondor.apana.org.au>
	<Pine.LNX.4.64.0708161743500.13267@kivilampi-30.cs.helsinki.fi>
	<46C4ABA5.9010804@redhat.com>
	<Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Chris Snook <csnook@redhat.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Satyam Sharma <satyam@infradead.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
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
To: Christoph Lameter <clameter@sgi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:36783 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933192AbXHQCpF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 22:45:05 -0400
In-Reply-To: <Pine.LNX.4.64.0708161319000.17777@schroedinger.engr.sgi.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph Lameter writes:

> No it does not have any volatile semantics. atomic_dec() can be reordered 
> at will by the compiler within the current basic unit if you do not add a 
> barrier.

Volatile doesn't mean it can't be reordered; volatile means the
accesses can't be eliminated.

Paul.
