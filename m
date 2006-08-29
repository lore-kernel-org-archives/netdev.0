From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Tue, 29 Aug 2006 23:04:57 +1000
Message-ID: <E1GI3Gz-0002vW-00@gondolin.me.apana.org.au>
References: <44F4258F.5070406@bieringer.de>
Cc: hasso@estpak.ee, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41744 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964884AbWH2NFJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 09:05:09 -0400
To: pb@bieringer.de (Peter Bieringer)
In-Reply-To: <44F4258F.5070406@bieringer.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Peter Bieringer <pb@bieringer.de> wrote:
>
>> anything in /proc/sys/net/ipv6/conf/<interface> because it doesn't exist.
>> 
>> How userspace should behave now? Mandating daemon which listens interface 
>> events via netlink?
> 
> BTW: this is also the reason why autoconf or accept_ra cannot be
> disabled by e.g. initscripts *per* interface before bringing one up.

You can disable it in /proc/sys/net/ipv6/conf/default/... and then
reenable it on the interfaces that you actually want.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
