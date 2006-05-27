From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [1/4] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Sat, 27 May 2006 22:08:01 +1000
Message-ID: <E1FjxaL-0002Gv-00@gondolin.me.apana.org.au>
References: <20060527.210519.119151107.yoshfuji@linux-ipv6.org>
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49676 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751483AbWE0MIM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 08:08:12 -0400
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20060527.210519.119151107.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> In article <20060527113345.GA4737@gondor.apana.org.au> (at Sat, 27 May 2006 21:33:45 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:
> 
>> As far as I can gather it's an attempt to guard against the removal of
>> the corresponding modules.  Since neither module can be unloaded at all
>> we can leave it to whoever fixes up IPv6 unloading :)
> 
> I disagree. Please do not add another mess.

Please don't get me wrong.  What I removed here doesn't work at all to
begin with.  I was just pointing out the possible reason why this code
existed in the first place.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
