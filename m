From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v4] gro: __napi_gro_receive() optimizations
Date: Thu, 26 Aug 2010 22:03:18 -0700 (PDT)
Message-ID: <20100826.220318.59661196.davem@davemloft.net>
References: <1282883713.2501.29.camel@edumazet-laptop>
	<20100826.213816.112615295.davem@davemloft.net>
	<1282885294.2501.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52991
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753393Ab0H0FDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 01:03:03 -0400
In-Reply-To: <1282885294.2501.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 27 Aug 2010 07:01:34 +0200

> compare_ether_header() can have a special implementation on 64 bit
> arches if CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS is defined.
> 
> __napi_gro_receive() and vlan_gro_common() can avoid a conditional
> branch to perform device match.
> 
> On x86_64, __napi_gro_receive() has now 38 instructions instead of 53
> 
> As gcc-4.4.3 still choose to not inline it, add inline keyword to this
> performance critical function.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
