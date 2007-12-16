From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.24-rc5-mm1: cat /proc/net/packet -> oops
Date: Sun, 16 Dec 2007 11:07:07 +0800
Message-ID: <E1J3jqN-0000Jq-00@gondolin.me.apana.org.au>
References: <200712160118.58611.m.kozlowski@tuxland.pl>
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, den@openvz.org, xemul@openvz.org
To: m.kozlowski@tuxland.pl (Mariusz Kozlowski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2405 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753111AbXLPDHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Dec 2007 22:07:22 -0500
In-Reply-To: <200712160118.58611.m.kozlowski@tuxland.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mariusz Kozlowski <m.kozlowski@tuxland.pl> wrote:
>
> git-ubi.patch
> GOOD
> #
> git-net.patch 
> BAD
> ipsec-fix-reversed-icmp6-policy-check.patch
> 
> but this seems to be far from precise :)

I suspect namespace borkage.  But just because you pin-pointed
my patch I'll try to track it down :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
