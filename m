From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next-2.6 0/5] Add support for software UDP
	fragmentation offload(UFO)
Date: Fri, 10 Jul 2009 09:04:05 +0800
Message-ID: <20090710010405.GA32639@gondor.apana.org.au>
References: <1247162981.8649.89.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51162 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750912AbZGJBEL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 21:04:11 -0400
Content-Disposition: inline
In-Reply-To: <1247162981.8649.89.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 09, 2009 at 11:09:41AM -0700, Sridhar Samudrala wrote:
> The following set of patches fixes support for UDP fragmentation offload
> in the core networking stack to send/receive large UDP packets over UFO
> enabled devices and fallback to software UFO when the outgoing device 
> doesn't support UFO.
> These patches enable setting UFO on virtio-net and tap devices and allow
> large UDP packets to be sent between guest to host and inter guest under
> KVM.
> 
> [PATCH net-next-2.6 1/5] udpv4: Handle large incoming UDP/IPv4 packets and support software UFO.
> [PATCH net-next-2.6 2/5] udpv6: Fix HW checksum support for outgoing UFO packets
> [PATCH net-next-2.6 3/5] udpv6: Fix gso_size setting in ip6_ufo_append_data
> [PATCH net-next-2.6 4/5] udpv6: Remove unused skb argument of ipv6_select_ident()
> [PATCH net-next-2.6 5/5] udpv6: Handle large incoming UDP/IPv6 packets and support software UFO

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
