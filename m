From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: TKIP encryption should allocate enough tailroom
Date: Wed, 17 Jan 2007 17:34:54 +1100
Message-ID: <E1H74Nq-0006N5-00@gondolin.me.apana.org.au>
References: <877ivm72cs.fsf@ten22.rhodesmill.org>
Cc: mitch@sfgoth.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2668 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751127AbXAQGfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 01:35:08 -0500
To: brandon@rhodesmill.org (Brandon Craig Rhodes)
In-Reply-To: <877ivm72cs.fsf@ten22.rhodesmill.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Brandon Craig Rhodes <brandon@rhodesmill.org> wrote:
> 
> Egads!  You are correct.
> 
> My intention was to preserve the value of "err" if an unsuccessful
> value was returned by skb_padto(), and otherwise to return "-1" which
> seemed the popular value used for errors elsewhere in the code.
> 
> - Would the expression "err ? err : -1" have served me better?
> - Do error codes mean anything here, or should I simply say "return -1"?

err ?: -1

should work.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
