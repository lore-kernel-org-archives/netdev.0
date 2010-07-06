From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6] net: Fix definition of netif_vdbg() when
 VERBOSE_DEBUG is defined
Date: Mon, 05 Jul 2010 20:08:33 -0700 (PDT)
Message-ID: <20100705.200833.42782495.davem@davemloft.net>
References: <1278090524.2095.41.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	joe@perches.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757084Ab0GFDIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 23:08:19 -0400
In-Reply-To: <1278090524.2095.41.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 02 Jul 2010 18:08:44 +0100

> netif_vdbg() was originally defined as entirely equivalent to
> netdev_vdbg(), but I assume that it was intended to take the same
> parameters as netif_dbg() etc.  (Currently it is only used by the
> sfc driver, in which I worked on that assumption.)
> 
> In commit a4ed89c I changed the definition used when VERBOSE_DEBUG is
> not defined, but I failed to notice that the definition used when
> VERBOSE_DEBUG is defined was also not as I expected.  Change that to
> match netif_dbg() as well.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied to net-2.6, thanks.
