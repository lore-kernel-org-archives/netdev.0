From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH v1] tun: Cleanup error handling in tun_set_iff()
Date: Thu, 6 Aug 2009 20:10:44 +1000
Message-ID: <20090806101044.GA26589@gondor.apana.org.au>
References: <20090803161242.12947.14620.stgit@flek.lan> <m1ljlyvn9a.fsf@fess.ebiederm.org> <200908051738.43134.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53271 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751232AbZHFKKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 06:10:52 -0400
Content-Disposition: inline
In-Reply-To: <200908051738.43134.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 05, 2009 at 05:38:42PM -0400, Paul Moore wrote:
>
> My concern is that I believe that if the kernel fails at an operation it 
> should do all it can to unwind any actions it took in the course of attempting 
> to perform the requested operation.  Leaving a TUN device around in the case 
> of a tun_attach() failure seems like the kernel is being lazy, sure a user can 
> cleanup the device but why should they have to?

That particular tun_attach should never fail.  Perhaps you can
just add a WARN_ON.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
