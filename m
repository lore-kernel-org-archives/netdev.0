From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 07 Nov 2008 12:22:59 -0800 (PST)
Message-ID: <20081107.122259.246440353.davem@davemloft.net>
References: <20081106194032.GB31673@ioremap.net>
	<FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
	<20081107172810.GB15239@ioremap.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vlovich@qualcomm.com, johaahn@gmail.com, netdev@vger.kernel.org
To: zbr@ioremap.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58652
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750920AbYKGUXA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 15:23:00 -0500
In-Reply-To: <20081107172810.GB15239@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Evgeniy Polyakov <zbr@ioremap.net>
Date: Fri, 7 Nov 2008 20:28:10 +0300

> On Thu, Nov 06, 2008 at 11:53:35AM -0800, Lovich, Vitali (vlovich@qualcomm.com) wrote:
> > Are there any consequences to bypassing qdisc (other than not participating in any load balancing)?  Also, since any users using the tx ring approach would have to write new code, it would be part of the documentation that the send behaviour is optimized for the least latency and highest throughput, thus no guarantees and assumptions can be made about the path the data takes through the stack.
> 
> qdisc is a base for multiqueue NICs (and all others too now), you can not bypass it there.

Right.
