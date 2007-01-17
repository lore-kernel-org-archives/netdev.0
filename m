From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Wed, 17 Jan 2007 18:18:16 +1100
Message-ID: <E1H753o-0006TM-00@gondolin.me.apana.org.au>
References: <E1H74Nq-0006N5-00@gondolin.me.apana.org.au>
Cc: brandon@rhodesmill.org, mitch@sfgoth.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2923 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751657AbXAQHS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 02:18:28 -0500
To: herbert@gondor.apana.org.au (Herbert Xu)
In-Reply-To: <E1H74Nq-0006N5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> wrote:
>
>> - Would the expression "err ? err : -1" have served me better?
>> - Do error codes mean anything here, or should I simply say "return -1"?
> 
> err ?: -1
> 
> should work.

Actually, you should probably use a more meaningful error code
than -1.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
