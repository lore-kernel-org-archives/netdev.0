From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Multiple VLAN Registration Protocol (IEEE
 802.1Q-2011)
Date: Sun, 10 Feb 2013 20:40:12 -0500 (EST)
Message-ID: <20130210.204012.215447544627085371.davem@davemloft.net>
References: <1360379828-16302-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.ward@ll.mit.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60731 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751497Ab3BKBkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 20:40:14 -0500
In-Reply-To: <1360379828-16302-1-git-send-email-david.ward@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ward <david.ward@ll.mit.edu>
Date: Fri, 8 Feb 2013 22:17:05 -0500

> The Linux kernel currently implements the GARP VLAN Registration
> Protocol (GVRP) from IEEE 802.1Q-1998 (applicant-only participant).
> When the GVRP flag is set for a VLAN interface on a Linux host, the
> host advertises its membership in the VLAN to the attached bridge/
> switch, so that it is not necessary to manually configure the bridge/
> switch port to participate in the VLAN.
> 
> GVRP has been superseded by the Multiple VLAN Registration Protocol
> (MVRP) in IEEE 802.1Q-2011, which addresses scalability concerns about
> the earlier protocol.  The following patches add support for MVRP to
> the Linux kernel and iproute2 utility. They are based largely off of
> the existing implementation of GVRP, but have been modified for the
> new PDU structure and state machine.
> 
> This implementation was tested with two Juniper EX4200 switches.
> 
> Signed-off-by: David Ward <david.ward@ll.mit.edu>
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied to net-next, thanks David.
