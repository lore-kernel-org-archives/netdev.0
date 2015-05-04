From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ipv4: route: Fix sending IGMP messages
 with link address
Date: Mon, 04 May 2015 00:04:22 -0400 (EDT)
Message-ID: <20150504.000422.1021776084367855653.davem@davemloft.net>
References: <1430491194-16615-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59514 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbEDEEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 00:04:23 -0400
In-Reply-To: <1430491194-16615-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Fri,  1 May 2015 16:39:54 +0200

> In setups with a global scope address on an interface, and a lesser
> scope address on an interface sending IGMP reports, the reports can be
> sent using the other interfaces global scope address rather than the
> local interface address. RFC 2236 suggests:
> 
>      Ignore the Report if you cannot identify the source address of
>      the packet as belonging to a subnet assigned to the interface on
>      which the packet was received.
> 
> since such reports could be forged.
> 
> Look at the protocol when deciding if a RT_SCOPE_LINK address should
> be used for the packet.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied, thanks Andrew.
