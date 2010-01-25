From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sfc: Add workspace for GMAC bug workaround to MCDI
 MAC_STATS buffer
Date: Mon, 25 Jan 2010 15:50:08 -0800 (PST)
Message-ID: <20100125.155008.197703478.davem@davemloft.net>
References: <1264447680.2793.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33575
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751084Ab0AYXt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 18:49:56 -0500
In-Reply-To: <1264447680.2793.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 25 Jan 2010 19:28:00 +0000

> From: Guido Barzini <gbarzini@solarflare.com>
> 
> Due to a hardware bug in the SFC9000 family, the firmware must
> transfer raw GMAC statistics to host memory before aggregating them
> into the cooked (speed-independent) MAC statistics.  Extend the stats
> buffer to support this.
> 
> The length of the buffer is explicit in the MAC_STATS command, so this
> change is backward-compatible on both sides.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
