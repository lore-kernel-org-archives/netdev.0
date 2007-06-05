From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] [IPV4]: Restore old behaviour of default config
 values
Date: Mon, 04 Jun 2007 23:36:27 -0700 (PDT)
Message-ID: <20070604.233627.45515850.davem@davemloft.net>
References: <20070605062929.GA12024@gondor.apana.org.au>
	<E1HvSZM-0003AF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36099
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760684AbXFEGgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:36:12 -0400
In-Reply-To: <E1HvSZM-0003AF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 05 Jun 2007 16:31:04 +1000

> [IPV4]: Restore old behaviour of default config values
> 
> Previously inet devices were only constructed when addresses are added
> (or rarely in ipmr).  Therefore the default config values they get are
> the ones at the time of these operations.
> 
> Now that we're creating inet devices earlier, this changes the behaviour
> of default config values in an incompatible way (see bug #8519).
> 
> This patch creates a compromise by setting the default values at the
> same point as before but only for those that have not been explicitly
> set by the user since the inet device's creation.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Also applied, thanks a lot.
