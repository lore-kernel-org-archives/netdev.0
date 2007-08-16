From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: your mail
Date: Thu, 16 Aug 2007 08:32:26 +0800
Message-ID: <20070816003226.GA29491@gondor.apana.org.au>
References: <46C30540.2070603@s5r6.in-berlin.de> <alpine.LFD.0.999.0708151941150.16414@enigma.security.iitk.ac.in> <20070815145207.GA23106@gondor.apana.org.au> <46C3253F.5090707@s5r6.in-berlin.de> <20070815162722.GD9645@linux.vnet.ibm.com> <d4406222873856f472b9173a14a19aa2@kernel.crashing.org> <20070815185724.GH9645@linux.vnet.ibm.com> <alpine.LFD.0.999.0708160118330.16414@enigma.security.iitk.ac.in> <2d2eeab6276cab2e6cc5830d36a43b98@kernel.crashing.org> <alpine.LFD.0.999.0708160338520.22701@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Segher Boessenkool <segher@kernel.crashing.org>,
	horms@verge.net.au, Stefan Richter <stefanr@s5r6.in-berlin.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, ak@suse.de,
	netdev@vger.kernel.org, cfriesen@nortel.com,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	rpjday@mindspring.com, jesper.juhl@gmail.com,
	linux-arch@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>, zlynx@acm.org,
	clameter@sgi.com, schwidefsky@de.ibm.com,
	Chris Snook <csnook@redhat.com>, davem@davemloft.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	wensong@linux-vs.org, wjiang@resilience.com
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1435 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752840AbXHPAcz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 20:32:55 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0708160338520.22701@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 16, 2007 at 06:06:00AM +0530, Satyam Sharma wrote:
> 
> that are:
> 
> 	while ((atomic_read(&waiting_for_crash_ipi) > 0) && msecs) {
> 		mdelay(1);
> 		msecs--;
> 	}
> 
> where mdelay() becomes __const_udelay() which happens to be in another
> translation unit (arch/i386/lib/delay.c) and hence saves this callsite
> from being a bug :-)

The udelay itself certainly should have some form of cpu_relax in it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
