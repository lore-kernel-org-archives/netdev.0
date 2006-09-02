From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp: turn ABC off
Date: Sat, 02 Sep 2006 18:10:29 +1000
Message-ID: <E1GJQaD-0000nK-00@gondolin.me.apana.org.au>
References: <20060902072248.GA27419@2ka.mipt.ru>
Cc: shemminger@osdl.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1806 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750796AbWIBILO
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 2 Sep 2006 04:11:14 -0400
To: johnpol@2ka.mipt.ru (Evgeniy Polyakov)
In-Reply-To: <20060902072248.GA27419@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> On Fri, Sep 01, 2006 at 01:55:15PM -0700, Stephen Hemminger (shemminger@osdl.org) wrote:
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 111ff39..159fa3f 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -89,7 +89,7 @@ int sysctl_tcp_frto;
>>  int sysctl_tcp_nometrics_save;
>>  
>>  int sysctl_tcp_moderate_rcvbuf = 1;
>> -int sysctl_tcp_abc = 1;
>> +int sysctl_tcp_abc;
> 
> Since it is not static are you sure it will be zero?

Outside a function the static modifier merely modifies whether the
symbol is visible externally.  It does not control whether it gets
zeroed.  And yes this will get zeroed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

-- 
VGER BF report: U 0.49998
