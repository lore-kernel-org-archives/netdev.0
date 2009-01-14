From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 05/34]bnx2x: Setting the GSO_TYPE with LRO
Date: Thu, 15 Jan 2009 07:18:26 +1100
Message-ID: <20090114201826.GA23648@gondor.apana.org.au>
References: <1231961380.25524.0.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43677 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755858AbZANUSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 15:18:36 -0500
Content-Disposition: inline
In-Reply-To: <1231961380.25524.0.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eilon Greenstein <eilong@broadcom.com> wrote:
>> 
> This is far from bullet proof solution, but IMHO it is better set then
> not  this way, you stand a chance (depending on the output device
> capabilities)

The question is simple, does your hardware guarantee that on
output GSO will turn the packet into exactly the same sequence
of packets that was seen on input, with no changes (apart from
what the stack would have done to them anyway, e.g., TTL update)
whatsoever?

If not then you mustn't set this and also you must disable it
if forwarding/bridging is used.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
