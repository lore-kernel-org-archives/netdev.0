From: Segher Boessenkool <segher@kernel.crashing.org>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Sat, 18 Aug 2007 00:14:30 +0200
Message-ID: <1f265c14b28f2c5922059a130b1d8aa5@kernel.crashing.org>
References: <alpine.LFD.0.999.0708160815510.24380@enigma.security.iitk.ac.in> <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <20070816053945.GB32442@gondor.apana.org.au> <18115.62741.807704.969977@cargo.ozlabs.ibm.com> <20070816070907.GA964@gondor.apana.org.au> <46C40587.7050708@s5r6.in-berlin.de> <20070816081049.GA1431@gondor.apana.org.au> <46C41EE4.9090806@s5r6.in-berlin.de> <46C42767.4070104@s5r6.in-berlin.de> <20070816104250.GB2927@gondor.apana.org.au> <20070816163441.GB16957@linux.vnet.ibm.com> <46C512EB.7020603@yahoo.com.au>
Mime-Version: 1.0 (Apple Message framework v623)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, Christoph Lameter <clameter@sgi.com>,
	Paul Mackerras <paulus@samba.org>, heiko.carstens@de.ibm.com,
	Stefan Richter <stefanr@s5r6.in-berlin.de>, horms@verge.net.au,
	Satyam Sharma <satyam@infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	rpjday@mindspring.com, netdev@vger.kernel.org, ak@suse.de,
	cfriesen@nortel.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	schwidefsky@de.ibm.com, Chris Snook <csnook@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:45347 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754374AbXHQWR1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Aug 2007 18:17:27 -0400
In-Reply-To: <46C512EB.7020603@yahoo.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> (and yes, it is perfectly legitimate to
> want a non-volatile read for a data type that you also want to do
> atomic RMW operations on)

...which is undefined behaviour in C (and GCC) when that data is
declared volatile, which is a good argument against implementing
atomics that way in itself.


Segher

