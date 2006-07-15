From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: michael_mic in crypto api?
Date: Sat, 15 Jul 2006 20:37:24 +1000
Message-ID: <E1G1hWW-0004ec-00@gondolin.me.apana.org.au>
References: <200607132350.25755.michael.wu@mozilla.com>
Cc: jbenc@suse.cz, linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:63503 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1946019AbWGOKi0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 06:38:26 -0400
To: michael.wu@mozilla.com (Michael Wu)
In-Reply-To: <200607132350.25755.michael.wu@mozilla.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu <michael.wu@mozilla.com> wrote:
> 
> Is there really a point to having michael_mic in crypto api? The only users 
> are 802.11 stacks. I can imagine arc4 being used for other purposes, but 
> michael_mic is very much wireless only. The only advantage of keeping 
> michael_mic in crypto seems to be the testing code.

I suppose the question is that what do you gain by moving it out?
If all else being equal then it's better to have a standardised
interface for accessing it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
