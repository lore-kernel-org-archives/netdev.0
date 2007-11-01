From: David Miller <davem@davemloft.net>
Subject: Re: expected behavior of PF_PACKET on NETIF_F_HW_VLAN_RX device?
Date: Wed, 31 Oct 2007 21:50:25 -0700 (PDT)
Message-ID: <20071031.215025.195350296.davem@davemloft.net>
References: <20071031123359.3954befc@freepuppy.rosehill>
	<4729269A.6090606@candelatech.com>
	<47292A99.5070805@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43393
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751037AbXKAEu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 00:50:26 -0400
In-Reply-To: <47292A99.5070805@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 31 Oct 2007 18:23:37 -0700

> The code in AF_PACKET should fix the skb before passing to user
> space so that there is no difference between accel and non-accel
> hardware.  Internal choices shouldn't leak to user space.  Ditto,
> the receive checksum offload should be fixed up as well.

The hardware has stripped the VLAN header completely and has not
provided it to us at all.

In my opinion trying to cobble one up by hand using the known TAG is
worse than not providing a VLAN header at all.
