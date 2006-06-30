From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Fri, 30 Jun 2006 12:11:13 +1000
Message-ID: <20060630021113.GA28641@gondor.apana.org.au>
References: <Pine.GSO.4.10.10606291810490.12773-100000@guinness> <E1Fw604-0006yP-00@gondolin.me.apana.org.au> <20060630003906.GA27200@gondor.apana.org.au> <1151633211.21798.25.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org,
	jgarzik@pobox.com, shemminger@osdl.org,
	Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	sivakumar.subramani@neterion.com, Sriram.Rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:44549 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1750774AbWF3CL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 22:11:57 -0400
To: Michael Chan <mchan@broadcom.com>
Content-Disposition: inline
In-Reply-To: <1151633211.21798.25.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 29, 2006 at 07:06:51PM -0700, Michael Chan wrote:
>
> Don't we have a bigger problem if it doesn't support ECN with ipv6 TSO?
> We either have to disable ECN when TSO is enabled like we used to for
> ipv4, or provide the gso tcp segmentation for ipv6.  Right?

Good point.  In that case we should also add GSO for IPv6.  It shouldn't
be too bad because all we need to do is verify the integrity of the
extension headers in terms of their length, not their content.

I wonder if this chip handles all the extension headers or not.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
