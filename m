From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Only flood unregistered groups to routers
Date: Fri, 24 Jun 2011 17:53:47 -0700 (PDT)
Message-ID: <20110624.175347.1335501634665889751.davem@davemloft.net>
References: <20110623123912.GA29381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.hengli.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42506 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab1FYAxw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 20:53:52 -0400
In-Reply-To: <20110623123912.GA29381@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.hengli.com.au>
Date: Thu, 23 Jun 2011 20:39:12 +0800

> bridge: Only flood traffic for unregistered groups to routers
> 
> The bridge currently floods packets to groups that we have never
> seen before to all ports.  This is not required by RFC4541 and
> in fact it is not desirable in environment where traffic to
> unregistered group is always present.
> 
> This patch changes the behaviour so that we only send traffic
> to unregistered groups to ports marked as routers.
> 
> The user can always force flooding behaviour to any given port
> by marking it as a router.
> 
> Note that this change does not apply to traffic to 224.0.0.X
> as traffic to those groups must always be flooded to all ports.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
