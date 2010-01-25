From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/2] sfc: Add workspace for GMAC bug workaround to MCDI
	MAC_STATS buffer
Date: Mon, 25 Jan 2010 19:36:35 +0000
Message-ID: <1264448195.2793.6.camel@achroite.uk.solarflarecom.com>
References: <1264447680.2793.0.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48208 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837Ab0AYTgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2010 14:36:40 -0500
In-Reply-To: <1264447680.2793.0.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-01-25 at 19:28 +0000, Ben Hutchings wrote:
> From: Guido Barzini <gbarzini@solarflare.com>
> 
> Due to a hardware bug in the SFC9000 family, the firmware must
> transfer raw GMAC statistics to host memory before aggregating them
> into the cooked (speed-independent) MAC statistics.  Extend the stats
> buffer to support this.
> 
> The length of the buffer is explicit in the MAC_STATS command, so this
> change is backward-compatible on both sides.

David,

I forgot to note that this is meant for net-2.6.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

