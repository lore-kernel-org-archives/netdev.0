From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 4/4] net: ppp_generic - introduce net-namespace
	functionality
Date: Sun, 11 Jan 2009 22:20:19 +1100
Message-ID: <20090111112019.GA29691@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: gorcunov@gmail.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org
To: paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:39337 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750938AbZAKLUd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 06:20:33 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul Mackerras <paulus@samba.org> wrote:
> 
> This looks like a lot of uglification to me.  Why exactly do
> individual network drivers need to know or care about namespaces?

I think ppp is special because it's closer to the tunnel drivers
than a straight NIC driver which is why it needs this work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
