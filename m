From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Netpoll checksum issue
Date: Thu, 20 Apr 2006 07:33:45 +1000
Message-ID: <20060419213345.GA18997@gondor.apana.org.au>
References: <6d6a94c50604190922m189b9d99gdd428a870e12c2c3@mail.gmail.com> <20060419103153.64ef0054@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Aubrey <aubreylee@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37380 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751167AbWDSVdx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Apr 2006 17:33:53 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060419103153.64ef0054@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 19, 2006 at 10:31:53AM -0700, Stephen Hemminger wrote:
> The changes to how hardware receive checksums are handled broke
> the netpoll checksum code (for CHECKSUM_HW).  Since this is not at
> all performance critical, try this patch. It changes to always to
> normal software checksum.

Hmm, why don't we try to find out what's actually broken? Papering over
this means that we could miss driver bugs in future.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
