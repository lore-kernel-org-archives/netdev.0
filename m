From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix link behavior for SFP+ when
 driver is brought down
Date: Fri, 03 Dec 2010 10:15:12 -0800 (PST)
Message-ID: <20101203.101512.15225225.davem@davemloft.net>
References: <20101203133151.21637.52883.stgit@localhost.localdomain>
	<20101203.094215.229763630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	donald.c.skidmore@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39627
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752072Ab0LCSOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Dec 2010 13:14:45 -0500
In-Reply-To: <20101203.094215.229763630.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 03 Dec 2010 09:42:15 -0800 (PST)

> I fixed all of this up and applied it all, but this sort of stuff
> needs to be sorted out before I see the submission. :-)

These patches introduced the following new compile warnings,
please send me patches to fix them:

drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_up_complete':
drivers/net/ixgbe/ixgbe_main.c:3803:22: warning: comparison between 'enum ixgbe_phy_type' and 'enum ixgbe_media_type'
drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_down':
drivers/net/ixgbe/ixgbe_main.c:4125:22: warning: comparison between 'enum ixgbe_phy_type' and 'enum ixgbe_media_type'
drivers/net/ixgbe/ixgbe_main.c: In function 'ixgbe_probe':
drivers/net/ixgbe/ixgbe_main.c:7215:22: warning: comparison between 'enum ixgbe_phy_type' and 'enum ixgbe_media_type'

Thanks.
