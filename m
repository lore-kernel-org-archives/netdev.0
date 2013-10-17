From: David Miller <davem@davemloft.net>
Subject: Re: [net-next REPOST] 8390 ei_debug : Reenable the use of
 debugging in 8390 based chips
Date: Thu, 17 Oct 2013 15:59:53 -0400 (EDT)
Message-ID: <20131017.155953.174894765079484399.davem@davemloft.net>
References: <1381805161-18833-1-git-send-email-tedheadster@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tedheadster@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46737 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758649Ab3JQT7z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 15:59:55 -0400
In-Reply-To: <1381805161-18833-1-git-send-email-tedheadster@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Whitehead <tedheadster@gmail.com>
Date: Mon, 14 Oct 2013 22:46:01 -0400

> Ethernet boards based on the 8390 chip had an '#ifdef notdef' disabling the
> use of the debug variable ei_debug. Reenable it for those of us who still
> occasionally use it.
> 
> Also handle the case of the 'ne' driver which uses 8390p.o rather than
> 8390.o. In that case ei_debug is aliased to eip_debug so it doesn't clash
> with the previously exported ei_debug.
> 
> Signed-off-by: Matthew Whitehead <tedheadster@gmail.com>

I'd rather not encourage the use of things like this.

We have a standard, run time, way to enable and disable debugging
output on a per-netdevice basis.  And the "default" value of which can
be controlled by a module parameter if need be.

Please convert the driver to this method instead.

Thank you.
