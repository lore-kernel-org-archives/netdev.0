From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/11][TG3]: Fix TSO bugs.
Date: Sat, 05 May 2007 11:50:31 -0700 (PDT)
Message-ID: <20070505.115031.48397744.davem@davemloft.net>
References: <1178326308.4859.17.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53284
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754656AbXEESuo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 14:50:44 -0400
In-Reply-To: <1178326308.4859.17.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 04 May 2007 17:51:48 -0700

> [TG3]: Fix TSO bugs.
> 
> 1. Remove the check for skb->len greater than MTU when doing TSO.
> When the destination has a smaller MSS than the source, a TSO packet
> may be smaller than the MTU and we still need to process it as a TSO
> packet.
> 
> 2. On 5705A3 devices with TSO enabled, the DMA engine can hang due to a
> hardware bug.  This patch avoids the hanging condition by reducing the
> DMA burst size.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

I had a suspicion that TG3 had the same bug BNX2 did. :)

Applied, thanks a lot.
