From: "Paul Moore" <paul.moore@centrify.com>
Subject: xfrm selector generating IKE
Date: Mon, 23 Feb 2009 17:31:29 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:3597 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751411AbZBXBbe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 20:31:34 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090130063048.GA4702@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do you know which version of *swan generates xfrm selectors when it does
an SA ADD or UPDATE. I downloaded openswan 2.6.19 and it does not


-----Original Message-----
From: Herbert Xu [mailto:herbert@gondor.apana.org.au] 
Sent: Thursday, January 29, 2009 10:31 PM
To: Paul Moore
Cc: kaber@trash.net; davem@davemloft.net; netdev@vger.kernel.org
Subject: Re: port bound SAs

Paul Moore <paul.moore@centrify.com> wrote:
> aha - so with racoon (which uses pfkey) I cannot make this work

Either fix racoon to use xfrm or go with a properly maintained
key manager like one of the *swans.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
