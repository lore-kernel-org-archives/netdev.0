From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 14:19:19 +1000
Message-ID: <E1KYCV5-0002jW-00@gondolin.me.apana.org.au>
References: <48B452ED.1000308@hhs.nl>
Cc: dada1@cosmosbay.com, davej@redhat.com, netdev@vger.kernel.org
To: j.w.r.degoede@hhs.nl (Hans de Goede)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60750 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750703AbYH0ETh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 00:19:37 -0400
In-Reply-To: <48B452ED.1000308@hhs.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans de Goede <j.w.r.degoede@hhs.nl> wrote:
> Eric Dumazet wrote:
>
>> # dmesg | grep "TCP established hash"
>> TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
>> # time cat /proc/net/tcp >/dev/null
>> 
>> real    0m0.091s
>> user    0m0.001s
>> sys     0m0.090s
> 
> As quoted above my idle x86_64, using the exact same hash table size, running 
> 2.6.27-rc2.git1 uses 0.520 seconds for that same command, thats a difference of 
> more then a factor 50 !!

That looks like a factor of 5 to me, not 50.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
