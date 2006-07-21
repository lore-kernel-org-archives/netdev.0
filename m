From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: A question about linux/net/ipv4/ipcomp.c
Date: Fri, 21 Jul 2006 22:57:35 +1000
Message-ID: <E1G3uZT-0006Jz-00@gondolin.me.apana.org.au>
References: <7t7j27iqnx.fsf@seba.krasu.ru>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34309 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750701AbWGUM5n
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Jul 2006 08:57:43 -0400
To: ivl@krasu.ru (Igor V. Liferenko)
In-Reply-To: <7t7j27iqnx.fsf@seba.krasu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Igor V. Liferenko <ivl@krasu.ru> wrote:
>
> Would you please say why it's 60, and not 52?

The header length / 4 must fit within a single hexadecimal
digit.  Therefore the maximum is 15 * 4 = 60.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
