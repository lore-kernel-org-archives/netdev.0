From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Wed, 4 Feb 2009 23:01:23 +1100
Message-ID: <20090204120123.GA22116@gondor.apana.org.au>
References: <m3skmubktj.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, zbr@ioremap.net, jarkao2@gmail.com, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51487 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750837AbZBDMCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2009 07:02:09 -0500
Content-Disposition: inline
In-Reply-To: <m3skmubktj.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen <benny+usenet@amorsen.dk> wrote:
>
> Would it be possible to add a counter somewhere for this, or is that
> too expensive?

Yes a counter would be useful and is reasonable.  But you can
probably deduce it by just looking at slabinfo.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
