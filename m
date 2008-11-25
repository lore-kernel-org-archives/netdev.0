From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: more info on ipsec-related invalid trusize
Date: Tue, 25 Nov 2008 18:52:16 +0800
Message-ID: <E1L4vWi-0006zm-PX@gondolin.me.apana.org.au>
References: <20081125042752.GA4085@x200.localdomain>
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com (Alexey Dobriyan)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48593 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751334AbYKYLhS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 06:37:18 -0500
In-Reply-To: <20081125042752.GA4085@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan <adobriyan@gmail.com> wrote:
> http://bugzilla.kernel.org/show_bug.cgi?id=10996
> http://marc.info/?l=linux-netdev&m=122641698504902&w=2
> 
> SKB BUG: Invalid truesize (344) len=134, sizeof(sk_buff)=216
> 
> This correlates with ping6 the box to death with the following IPsec
> configuration and entering/leaving tcpdumping on the other end.

It's a known problem.  When we expand packet headers in IPsec
we're not adjusting the truesize.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
