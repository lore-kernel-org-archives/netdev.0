From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sfc: Call netif_napi_add() before registering our
 interrupt handler
Date: Tue, 31 Mar 2009 15:07:29 -0700 (PDT)
Message-ID: <20090331.150729.74805590.davem@davemloft.net>
References: <1238526464.3254.7.camel@achroite>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34510
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756701AbZCaWHk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 18:07:40 -0400
In-Reply-To: <1238526464.3254.7.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 31 Mar 2009 20:07:44 +0100

> If we use a shared legacy IRQ then our interrupt handler may be called
> as soon as it is registered even though IRQs are disabled on the NIC.
> Now that the legacy interrupt handler also checks for event delivery,
> it may decide to schedule polling in this case.  Ensure that the NAPI
> context is valid but disabled at this point.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
