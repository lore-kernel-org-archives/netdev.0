From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPSec kernel oops on ppc64
Date: Tue, 29 Aug 2006 11:30:23 +1000
Message-ID: <20060829013023.GA5865@gondor.apana.org.au>
References: <200608282225.k7SMPF80022173@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, gcwilson@us.ibm.com, jmorris@redhat.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:14854 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750905AbWH2Bbh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Aug 2006 21:31:37 -0400
To: Joy Latten <latten@austin.ibm.com>
Content-Disposition: inline
In-Reply-To: <200608282225.k7SMPF80022173@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 28, 2006 at 05:25:15PM -0500, Joy Latten wrote:
> 
> A straight 2.6.17 kernel does not crash and my pings work.
> A 2.6.17 + patch-2.6.18-rc4 does crash and my pings do not work.
> The above tests were done on a ppc64. 

Thanks for that info.  This does sound like a bug.

Could you please generate a dump of the stack/register contents and
a disassembly of the code around the crash?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
