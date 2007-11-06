From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.23] [PPP]: L2TP: Fix oops in transmit and receive
 paths
Date: Mon, 05 Nov 2007 23:33:15 -0800 (PST)
Message-ID: <20071105.233315.59663737.davem@davemloft.net>
References: <200711051717.lA5HHd9u013301@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44214
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755038AbXKFHdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 02:33:15 -0500
In-Reply-To: <200711051717.lA5HHd9u013301@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Chapman <jchapman@katalix.com>
Date: Mon, 5 Nov 2007 17:17:39 GMT

> [PPP]: L2TP: Fix oops in transmit and receive paths
> 
> Changes made on 18-sep to fix skb handling in the pppol2tp driver
> broke the transmit and receive paths. Users are only running into this
> now because distros are now using 2.6.23 and I must have messed up
> when I tested the change.
> 
> For receive, we now do our own calculation of how much to pull from
> the skb (variable length L2TP header) rather than using
> skb_transport_offset(). Also, if the skb isn't a data packet, it must
> be passed back to UDP with skb->data pointing to the UDP header.
> 
> For transmit, make sure skb->sk is set up because ip_queue_xmit()
> needs it.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, thanks James.

I'll queue this up for -stable too.
