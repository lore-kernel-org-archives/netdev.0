From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] raw: restore daddr_cache in raw kernel socket.
Date: Sat, 02 Aug 2008 08:52:37 +0800
Message-ID: <E1KP5ML-0006MS-00@gondolin.me.apana.org.au>
References: <4892DEB4.20203@miraclelinux.com>
Cc: usagi-users@linux-ipv6.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
To: nooiwa@miraclelinux.com (Naohiro Ooiwa)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37592 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750969AbYHBAwm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 20:52:42 -0400
In-Reply-To: <4892DEB4.20203@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Naohiro Ooiwa <nooiwa@miraclelinux.com> wrote:
> 
> I created a patch of RAW socket.
> 
> This patch adds ip6_sk_dst_lookup()/ip6_dst_store() in rawv6_sendmsg().
> so that RAW socket can use "daddr_cache".
> 
> When RAW socket sent the packets to same destination,
> it must reduce over-head.
> 
> Could you please check the following patch?

Please fix the IPsec issue in this thread first:

http://www.mail-archive.com/netdev@vger.kernel.org/msg07339.html

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
