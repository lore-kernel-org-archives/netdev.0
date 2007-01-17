From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 7832] New: if i use iproute2 for network balancing
Date: Wed, 17 Jan 2007 11:47:13 +1100
Message-ID: <E1H6yxN-0005p6-00@gondolin.me.apana.org.au>
References: <20070116135524.e0e39e5b.akpm@osdl.org>
Cc: netdev@vger.kernel.org, cw@f00f.org,
	bugme-daemon@bugzilla.kernel.org, gclarkx@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1163 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751146AbXAQArp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jan 2007 19:47:45 -0500
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20070116135524.e0e39e5b.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
>> /sbin/ip route change default equalize nexthop dev ppp0 nexthop dev ppp1
>> /sbin/ip route flush cache

Is CONFIG_IP_ROUTE_MULTICACHE turned on? If so does this still
happen if you disable it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
