From: Thomas Egerer <hakke_007@gmx.de>
Subject: Re: [PATCH] ipv4+ipv6: Make INET*_ESP select CRYPTO_ECHAINIV
Date: Mon, 25 Jan 2016 12:57:23 +0100
Message-ID: <56A60DA3.2030501@gmx.de>
References: <20160125102659.GA6976@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.21]:51018 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756713AbcAYL6Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 06:58:16 -0500
In-Reply-To: <20160125102659.GA6976@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2016 11:26 AM, Herbert Xu wrote:
> Thomas Egerer <hakke_007@gmx.de> wrote:
>> The ESP algorithms using CBC mode require echainiv. Hence INET*_ESP have
>> to select CRYPTO_ECHAINIV in order to work properly. This solves the
>> issues caused by a misconfiguration as described in [1].
>> The original approach, patching crypto/Kconfig was turned down by
>> Herbert Xu [2].
>>
>> [1] https://lists.strongswan.org/pipermail/users/2015-December/009074.html
>> [2] http://marc.info/?l=linux-crypto-vger&m=145224655809562&w=2
>>
>> Signed-off-by: Thomas Egerer <hakke_007@gmx.de>
>> ---
>> net/ipv4/Kconfig | 1 +
>> net/ipv6/Kconfig | 1 +
>> 2 files changed, 2 insertions(+)
>>
>> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
>> index c229205..7758247 100644
>> --- a/net/ipv4/Kconfig
>> +++ b/net/ipv4/Kconfig
>> @@ -353,6 +353,7 @@ config INET_ESP
>>        select CRYPTO_CBC
>>        select CRYPTO_SHA1
>>        select CRYPTO_DES
>> +       select CRYPTO_ECHAINIV
>>        ---help---
>>          Support for IPsec ESP.
>>
>> diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
>> index bb7dabe..40c8975 100644
>> --- a/net/ipv6/Kconfig
>> +++ b/net/ipv6/Kconfig
>> @@ -69,6 +69,7 @@ config INET6_ESP
>>        select CRYPTO_CBC
>>        select CRYPTO_SHA1
>>        select CRYPTO_DES
> 
> Your patch seems to be missing a few lines at the end.
That's odd, yet the my outbox contains a truncated mail, too.
Sorry, will resend the patch in a jiff.

Thomas
> Otherwise it looks good to me.
> 
> Cheers,
> 
