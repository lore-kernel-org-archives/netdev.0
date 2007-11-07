From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Fix unicast timeouts
Date: Wed, 07 Nov 2007 02:42:29 -0800 (PST)
Message-ID: <20071107.024229.248193373.davem@davemloft.net>
References: <472DF8E8.2030204@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: manfred@colorfullife.com, netdev@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57500
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbXKGKm3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:42:29 -0500
In-Reply-To: <472DF8E8.2030204@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Sun, 04 Nov 2007 17:52:56 +0100

> [NETLINK]: Fix unicast timeouts
> 
> Commit ed6dcf4a in the history.git tree broke netlink_unicast timeouts by
> moving the schedule_timeout() call to a new function that doesn't propagate
> the remaining timeout back to the caller. This means on each retry we start
> with the full timeout again.
> 
> ipc/mqueue.c seems to actually want to wait indefinitely so this behaviour
> is retained.
> 
> Cc: Manfred Spraul <manfred@colorfullife.com>
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied, and I'll queue this up for -stable, thanks Patrick!
