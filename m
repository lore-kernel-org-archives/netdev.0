From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24-rc5-mm1
Date: Fri, 14 Dec 2007 11:26:46 -0800 (PST)
Message-ID: <20071214.112646.189940492.davem@davemloft.net>
References: <4761494E.1050704@bull.net>
	<20071213.094554.136920553.davem@davemloft.net>
	<20071214020807.GA12426@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benjamin.thery@bull.net, pierre.peiffer@bull.net,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53115
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760266AbXLNT0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Dec 2007 14:26:55 -0500
In-Reply-To: <20071214020807.GA12426@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 14 Dec 2007 10:08:07 +0800

> [UDP]: Move udp_stats_in6 into net/ipv4/udp.c
> 
> Now that external users may increment the counters directly, we need to
> ensure that udp_stats_in6 is always available.  Otherwise we'd either
> have to requrie the external users to be built as modules or ipv6 to be
> built-in.
> 
> This isn't too bad because udp_stats_in6 is just a pair of pointers plus
> an EXPORT, e.g., just 40 (16 + 24) bytes on x86-64.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
