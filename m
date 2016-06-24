From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: esp: Fix ESN generation under UDP encapsulation
Date: Fri, 24 Jun 2016 09:52:51 +0800
Message-ID: <20160624015251.GB15308@gondor.apana.org.au>
References: <20160620105934.GL7698@gauss.secunet.com>
 <576B64B1.9030000@alliedtelesis.co.nz>
 <20160623104007.GO7698@gauss.secunet.com>
 <20160623.115245.451201603985254809.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steffen.klassert@secunet.com, Blair.Steven@alliedtelesis.co.nz,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:45779 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750847AbcFXBxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 21:53:00 -0400
Content-Disposition: inline
In-Reply-To: <20160623.115245.451201603985254809.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 11:52:45AM -0400, David Miller wrote:
> 
> Does the ipv6 side need the same fix?

Last I checked IPv6 didn't do IPsec UDP-encapsulation so we're
safe for now.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
