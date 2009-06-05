From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: virtio_net: Set correct gso->hdr_len
Date: Fri, 5 Jun 2009 14:27:09 +1000
Message-ID: <20090605042709.GA6702@gondor.apana.org.au>
References: <20090604105917.GA28273@gondor.apana.org.au> <200906051351.06385.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43464 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750701AbZFEE1N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2009 00:27:13 -0400
Content-Disposition: inline
In-Reply-To: <200906051351.06385.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 05, 2009 at 01:51:05PM +0930, Rusty Russell wrote:
>
> But are we allowed to make the assumption that skb_headlen() == 
> skb_transport_header(skb) + sizeof(transport header) ?  Or should we be 
> checking that here?

We don't care.  We just want to preserve whatever the OS gave us.
If it's bogus, the backend will reject it or fix it up.

> Also how did this ever work?  Why are we getting packets through at all?

Because the backend fixed it up.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
