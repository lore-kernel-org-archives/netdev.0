From: David Miller <davem@davemloft.net>
Subject: Re: [rfc] bridge: is PACKET_LOOPBACK unlikely()?
Date: Sun, 22 Aug 2010 21:14:36 -0700 (PDT)
Message-ID: <20100822.211436.212698198.davem@davemloft.net>
References: <20100823033532.GA28463@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jpirko@redhat.com, shemminger@linux-foundation.org,
	jesse@nicira.com
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34948
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751128Ab0HWEOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 00:14:19 -0400
In-Reply-To: <20100823033532.GA28463@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Mon, 23 Aug 2010 12:35:32 +0900

> While looking at using netdev_rx_handler_register for openvswitch Jesse
> Gross suggested that an unlikely() might be worthwhile in that code.
> I'm interested to see if its appropriate for the bridge code.
> 
> Cc: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Seems reasonable to me, applied to net-next-2.6
