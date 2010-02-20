From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] sfc: SFE4002/SFN4112F: Widen temperature
 and voltage tolerances
Date: Fri, 19 Feb 2010 17:03:06 -0800 (PST)
Message-ID: <20100219.170306.112995626.davem@davemloft.net>
References: <1266622444.2091.10.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37334
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752986Ab0BTBCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 20:02:50 -0500
In-Reply-To: <1266622444.2091.10.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 19 Feb 2010 23:34:03 +0000

> The temperature and voltage limits currently set on these boards are
> too conservative and will cause the driver to stop the net device
> erroneously in some systems.
> 
> Based on a review of the chip datasheets and advice from the designer
> of these boards:
> 
> - Raise the maximum board temperatures to the specified maximum ambient
>   temperatures for their PHYs plus the expected temperature bias of the
>   board
> - Raise the maximum controller temperature to 90 degrees
> - Lower the minimum temperatures to 0 degrees
> - Widen the voltage tolerances to at least +/- 10%
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
