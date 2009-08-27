From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] sfc: Fix ordering of device registration and
 initial netif_carrier_off()
Date: Wed, 26 Aug 2009 18:03:58 -0700 (PDT)
Message-ID: <20090826.180358.229467239.davem@davemloft.net>
References: <1251310587.27345.9.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53155
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754479AbZH0BDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 21:03:45 -0400
In-Reply-To: <1251310587.27345.9.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Wed, 26 Aug 2009 19:16:27 +0100

> We must call netif_carrier_off() after the device is registered, not
> before, to set the operational state and user-space IFF_RUNNING flag
> correctly.
> 
> Since we don't want observers to see an intermediate state, open-code
> register_netdev() and add efx_update_name() and netif_carrier_off()
> into the locked region.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
