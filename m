From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] Fixing up TCP/UDP checksum for UDP encap. ESP4 packets
	in transport mode
Date: Tue, 7 Jul 2009 10:21:01 +0800
Message-ID: <20090707022101.GA27525@gondor.apana.org.au>
References: <20090707014008.GA27100@gondor.apana.org.au> <20090706.185411.136676235.davem@davemloft.net> <20090707015850.GA27305@gondor.apana.org.au> <20090706.190235.248640426.davem@davemloft.net> <20090707021845.GA27460@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: christophe@saout.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36561 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754091AbZGGCVC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 22:21:02 -0400
Content-Disposition: inline
In-Reply-To: <20090707021845.GA27460@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 07, 2009 at 10:18:45AM +0800, Herbert Xu wrote:
> On Mon, Jul 06, 2009 at 07:02:35PM -0700, David Miller wrote:
> >
> > Indeed, there is no way to handle checksums sanely.  The whole
> > end-to-end protection of the checksum would be entirely subverted
> > if we fixed it up.

Oh and if we were going to fix it up, it'd make much more sense
as an explicit netfilter target so people know what they're
getting themselves into.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
