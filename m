From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] inet_peer : group together avl_left, avl_right,
 v4daddr to speedup lookups on some CPUS
Date: Wed, 18 Oct 2006 20:44:20 -0700 (PDT)
Message-ID: <20061018.204420.118952167.davem@davemloft.net>
References: <20061016.223513.35356292.davem@davemloft.net>
	<200610171458.37636.dada1@cosmosbay.com>
	<200610180938.39175.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15503
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423240AbWJSDoK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 23:44:10 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200610180938.39175.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 18 Oct 2006 09:38:38 +0200

> Lot of routers still use CPUS with 32 bytes cache lines. (Intel PIII)
> It make sense to make sure fields used at lookup time are in the same cache 
> line, to reduce cache footprint and speedup lookups.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Looks fine but patch doesn't apply:

-	__u32			v4daddr;	/* peer's address */

in my tree v4daddr is a __be32, not a __u32.
