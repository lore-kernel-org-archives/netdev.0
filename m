From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH]IPv6:remove duplicate check of optlen when setsockopt
	with IPV6_PKTINFO option
Date: Wed, 14 Jan 2009 14:47:11 +1100
Message-ID: <20090114034711.GA8361@gondor.apana.org.au>
References: <496C445E.1000707@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Yang Hongyang <yanghy@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40366 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752424AbZANDrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 22:47:15 -0500
Content-Disposition: inline
In-Reply-To: <496C445E.1000707@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yang Hongyang <yanghy@cn.fujitsu.com> wrote:
> Actually the condition (optlen == 0) is included in (optlen < sizeof(struct in6_pktinfo)),
> so we do not need to check it separately.

You don't need to check optval == NULL either since that's the
job of copy_from_user.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
