From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC 1/2] bridge: avoid ptype_all packet handling
Date: Sat, 03 Mar 2007 16:38:45 +1100
Message-ID: <E1HNMxB-0000MP-00@gondolin.me.apana.org.au>
References: <20070302.151803.74748558.davem@davemloft.net>
Cc: shemminger@linux-foundation.org, bridge@linux-foundation.org,
	netdev@vger.kernel.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3891 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933368AbXCCFj1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2007 00:39:27 -0500
In-Reply-To: <20070302.151803.74748558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> I'm tempted to say I must be missing something here, since I can't see
> how this could possible work at all.  The string passed in should
> be interpreted as the ifindex value, and thus trigger a -ENODEV
> return from AF_PACKET's bind() implementation.

This is using packet_bind_spkt which uses a name instead of ifindex.

As you may recall, I've made a patch to convert it to use the new
(actually it's not-so-new anymore) AF_PACKET interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
