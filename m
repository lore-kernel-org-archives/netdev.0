From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Bug in pskb_trim_rcsum()
Date: Mon, 17 Jul 2006 22:17:43 +1000
Message-ID: <E1G2S2h-0000nq-00@gondolin.me.apana.org.au>
References: <1153108401.3651.9.camel@LINE>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:30730 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750757AbWGQMRv
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Jul 2006 08:17:51 -0400
To: yjwei@nanjing-fnst.com (Wei Yongjun)
In-Reply-To: <1153108401.3651.9.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wei Yongjun <yjwei@nanjing-fnst.com> wrote:
>
>  So if I want to trim a skb, I think I must do a checksum even if the
> skb->ip_summed is CHECKSUM_UNNECESSARY.

Nope.  CHECKSUM_UNNECESSARY means that the hardware has already
verified the checksum to be correct for the given protocol.
Trimming a packet does not affect it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
