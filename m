From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 0/24] make atomic_read() behave consistently across all architectures
Date: Mon, 10 Sep 2007 19:15:55 +0800
Message-ID: <20070910111555.GA27221@gondor.apana.org.au>
References: <18115.52863.638655.658466@cargo.ozlabs.ibm.com> <200709091902.55388.vda.linux@googlemail.com> <20070909191839.1fa10e88@laptopd505.fenrus.org> <200709101156.30010.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arjan van de Ven <arjan@infradead.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Nick Piggin <piggin@cyberone.com.au>,
	Satyam Sharma <satyam@infradead.org>,
	Paul Mackerras <paulus@samba.org>,
	Christoph Lameter <clameter@sgi.com>,
	Chris Snook <csnook@redhat.com>,
	Ilpo Jarvinen <ilpo.jarvinen@helsinki.fi>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	linux-arch@vger.kernel.org, Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, ak@suse.de,
	heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>,
	schwidefsky@de.ibm.com, wensong@linux-vs.org, horms@verge.net.au,
	wjiang@resilience.com, cfriesen@nortel.com, zlynx@acm.org,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	segher@kernel.crashing.org
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1295 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933409AbXIJLXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 07:23:24 -0400
Content-Disposition: inline
In-Reply-To: <200709101156.30010.vda.linux@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2007 at 11:56:29AM +0100, Denys Vlasenko wrote:
> 
> Expecting every driver writer to remember that atomic_read is not in fact
> a "read from memory" is naive. That won't happen. Face it, majority of
> driver authors are a bit less talented than Ingo Molnar or Arjan van de Ven ;)
> The name of the macro is saying that it's a read.
> We are confusing users here.

For driver authors who're too busy to learn the intricacies
of atomic operations, we have the plain old spin lock which
then lets you use normal data structures such as u32 safely.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
