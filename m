From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] can: Use WARN_ONCE() instead of BUG_ON()
 for sanity check in receive path
Date: Fri, 14 Aug 2009 16:37:26 -0700 (PDT)
Message-ID: <20090814.163726.52442387.davem@davemloft.net>
References: <4A852641.80305@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: urs@isnogud.escape.de, l.fu@pengutronix.de,
	m.olbrich@pengutronix.de, netdev@vger.kernel.org
To: oliver@hartkopp.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55302
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756149AbZHNXhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 19:37:16 -0400
In-Reply-To: <4A852641.80305@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Oliver Hartkopp <oliver@hartkopp.net>
Date: Fri, 14 Aug 2009 10:54:25 +0200

> To ensure a proper handling of CAN frames transported in skbuffs some checks
> need to be performed at receive time.
> 
> As stated by Michael Olbrich and Luotao Fu BUG_ON() might be to restrictive.
> This is right as we can just drop the non conform skbuff and the Kernel can
> continue working.
> 
> This patch replaces the BUG_ON() with a WARN_ONCE() so that the system remains
> healthy but we made the problem visible (once).
> 
> Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
> Signed-off-by: Urs Thuermann <urs@isnogud.escape.de>

Applied, thanks.
