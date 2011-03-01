From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Reduce size of efx_rx_buffer by
 unionising skb and page
Date: Tue, 01 Mar 2011 13:08:58 -0800 (PST)
Message-ID: <20110301.130858.260088073.davem@davemloft.net>
References: <1298942490.3069.180.camel@localhost>
	<20110301.122459.183051942.davem@davemloft.net>
	<1299012424.2529.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50348
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757226Ab1CAVIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 16:08:22 -0500
In-Reply-To: <1299012424.2529.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 01 Mar 2011 20:47:04 +0000

> Combining the flag with the pointers wouldn't improve on this:

Good point, but:

1) One less load in your RX fast path.

2) 32-bits of space for any addition state you might like to add later
