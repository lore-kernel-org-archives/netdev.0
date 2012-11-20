From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next] add DOVE extensions for VXLAN
Date: Tue, 20 Nov 2012 13:41:53 -0500 (EST)
Message-ID: <20121120.134153.1601157241229102533.davem@davemloft.net>
References: <201211201251.qAKCoEN8003256@lab1.dls>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751582Ab2KTSlz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 13:41:55 -0500
In-Reply-To: <201211201251.qAKCoEN8003256@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David L Stevens <dlstevens@us.ibm.com>
Date: Tue, 20 Nov 2012 07:50:14 -0500

> 
> 	This patch provides extensions to VXLAN for supporting Distributed
> Overlay Virtual Ethernet (DOVE) networks. The patch includes:
> 
> 	+ a dove flag per VXLAN device to enable DOVE extensions
> 	+ ARP reduction, whereby a bridge-connected VXLAN tunnel endpoint
> 		answers ARP requests from the local bridge on behalf of
> 		remote DOVE clients
> 	+ route short-circuiting (aka L3 switching). Known destination IP
> 		addresses use the corresponding destination MAC address for
> 		switching rather than going to a (possibly remote) router first.
> 	+ netlink notification messages for forwarding table and L3 switching
> 		misses
> 
> Changes since v2
> 	- combined bools into "u32 flags"
> 	- replaced loop with !is_zero_ether_addr()
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Applied, thanks David.
