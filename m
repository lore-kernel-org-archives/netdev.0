From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] [IPV4]: Add default config support after
 inetdev_init
Date: Mon, 04 Jun 2007 23:35:47 -0700 (PDT)
Message-ID: <20070604.233547.122619624.davem@davemloft.net>
References: <20070605062929.GA12024@gondor.apana.org.au>
	<E1HvSZL-0003AB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36096
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760462AbXFEGfd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:35:33 -0400
In-Reply-To: <E1HvSZL-0003AB-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 05 Jun 2007 16:31:03 +1000

> [IPV4]: Add default config support after inetdev_init
> 
> Previously once inetdev_init has been called on a device any changes made
> to ipv4_devconf_dflt would have no effect on that device's configuration.
> 
> This creates a problem since we have moved the point where inetdev_init
> is called from when an address is added to where the device is registered.
> 
> This patch is the first half of a set that tries to mimic the old behaviour
> while still calling inetdev_init.
> 
> It propagates any changes to ipv4_devconf_dflt to those devices that have
> not had the corresponding attribute set.
> 
> The next patch will forcibly set all values at the point where inetdev_init
> was previously called.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks good, applied.
