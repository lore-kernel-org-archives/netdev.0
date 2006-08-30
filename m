From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC IPv6] Disabling IPv6 autoconf
Date: Wed, 30 Aug 2006 10:12:10 +1000
Message-ID: <E1GIDgg-00043h-00@gondolin.me.apana.org.au>
References: <200608291659.49876.hasso@estpak.ee>
Cc: herbert@gondor.apana.org.au, pb@bieringer.de,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51974 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965180AbWH3AMi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Aug 2006 20:12:38 -0400
To: hasso@estpak.ee (Hasso Tepper)
In-Reply-To: <200608291659.49876.hasso@estpak.ee>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hasso Tepper <hasso@estpak.ee> wrote:
>
>> You can disable it in /proc/sys/net/ipv6/conf/default/... and then
>> reenable it on the interfaces that you actually want.
> 
> You can't do that either (ie. reenable) in initscripts before link is up.

As soon as you do ifconfig ethX up it'll appear in /proc/sys and
you can reenable it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
