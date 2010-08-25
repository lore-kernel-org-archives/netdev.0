From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6] gro: __napi_gro_receive() optimizations
Date: Wed, 25 Aug 2010 13:45:47 -0700
Message-ID: <20100825134547.0ecc4f11@nehalam>
References: <1282768431.2681.144.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60105 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752287Ab0HYUpt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Aug 2010 16:45:49 -0400
In-Reply-To: <1282768431.2681.144.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 25 Aug 2010 22:33:51 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> compare_ether_header() can have a special implementation on 64 bit
> arches if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined
> 
> __napi_gro_receive() can avoid a conditional branch to perform device
> match.
> 
> __napi_gro_receive() can be used from vlan_gro_common() instead of being
> duplicated.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Please, 2 patches. not mixing unrelated bits in one patch.
