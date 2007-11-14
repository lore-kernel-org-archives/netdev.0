From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 9/24] [IPSEC]: Replace x->type->{local,remote}_addr
 with flags
Date: Tue, 13 Nov 2007 21:37:04 -0800 (PST)
Message-ID: <20071113.213704.76981363.davem@davemloft.net>
References: <20071107140701.GA4685@gondor.apana.org.au>
	<E1IplZx-0001H5-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37455
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758130AbXKNFhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 00:37:04 -0500
In-Reply-To: <E1IplZx-0001H5-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 07 Nov 2007 22:08:25 +0800

> [IPSEC]: Replace x->type->{local,remote}_addr with flags
> 
> The functions local_addr and remote_addr are more than what they're needed
> for.  The same thing can be done easily with flags on the type object.
> This patch does that and simplifies the wrapper functions in xfrm6_policy
> accordingly.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25
