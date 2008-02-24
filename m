From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: ethtool phys_id default (rev2)
Date: Sat, 23 Feb 2008 19:52:21 -0800 (PST)
Message-ID: <20080223.195221.177613282.davem@davemloft.net>
References: <20080222102429.7e48f1f1@extreme>
	<1203707802.13495.169.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jgarzik@pobox.com, netdev@vger.kernel.org
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41050
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752432AbYBXDvm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 22:51:42 -0500
In-Reply-To: <1203707802.13495.169.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 22 Feb 2008 11:16:42 -0800

> On Fri, 2008-02-22 at 10:24 -0800, Stephen Hemminger wrote:
> > When asked to blink LEDs the tg3 driver behaves when using:
> > 	ethtool -p ethX
> > The default value for data is zero, and other drivers interpret this
> > as blink forever (or at least a really long time).  The tg3 driver
> > interprets this as blink once.  All drivers should have the same
> > behaviour.
> > 
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied.

> We should do this across the board for bnx2, bnx2x, and niu as well.

Agreed.
