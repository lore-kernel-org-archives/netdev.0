From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: skip forwarding delay if not using STP
Date: Mon, 14 Mar 2011 15:07:08 -0700 (PDT)
Message-ID: <20110314.150708.116369703.davem@davemloft.net>
References: <20110310075704.47f91bd5@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751659Ab1CNWGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 18:06:30 -0400
In-Reply-To: <20110310075704.47f91bd5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 10 Mar 2011 07:57:04 -0800

> If Spanning Tree Protocol is not enabled, there is no good reason for
> the bridge code to wait for the forwarding delay period before enabling
> the link. The purpose of the forwarding delay is to allow STP to
> learn about other bridges before nominating itself.
> 
> The only possible impact is that when starting up a new port
> the bridge may flood a packet now, where previously it might have
> seen traffic from the other host and preseeded the forwarding table.
> 
> Includes change for local variable br already available in that func.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied to net-2.6, thanks.
