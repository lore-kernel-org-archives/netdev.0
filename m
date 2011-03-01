From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Reduce size of efx_rx_buffer by
 unionising skb and page
Date: Tue, 01 Mar 2011 12:24:59 -0800 (PST)
Message-ID: <20110301.122459.183051942.davem@davemloft.net>
References: <1298942169.3069.179.camel@localhost>
	<1298942490.3069.180.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52506
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757148Ab1CAUYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 15:24:22 -0500
In-Reply-To: <1298942490.3069.180.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 01 Mar 2011 01:21:30 +0000

> From: Steve Hodgson <shodgson@solarflare.com>
> 
> [bwh: Forward-ported to net-next-2.6.]
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

I'm going to apply this, but you can take this further by making
the buffer an "unsigned long" and encode the pointer plus a one-bit
binary state there to indicate what it is.
