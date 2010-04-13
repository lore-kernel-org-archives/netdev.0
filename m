From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix some #includes in CAN drivers
Date: Tue, 13 Apr 2010 01:36:14 -0700 (PDT)
Message-ID: <20100413.013614.200995710.davem@davemloft.net>
References: <20100408192545.GD2004@bluebox.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org,
	kernel@pengutronix.de, 21cnbao@gmail.com, celston@katalix.com,
	chripell@evolware.org, wg@grandegger.com, haas@ems-wuenche.com,
	per.dalen@cnw.se, P.B.Cheblakov@inp.nsk.su,
	oliver.hartkopp@volkswagen.de, anantgole@ti.com
To: hjk@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38283
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752172Ab0DMIgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 04:36:11 -0400
In-Reply-To: <20100408192545.GD2004@bluebox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hans J. Koch" <hjk@linutronix.de>
Date: Thu, 8 Apr 2010 21:25:45 +0200

> In the current implementation, CAN drivers need to #include <linux/can.h>
> _before_ they #include <linux/can/dev.h>, which is both ugly and
> unnecessary.
> 
> Fix this by including <linux/can.h> in <linux/can/dev.h> and remove the
> #include <linux/can.h> lines from drivers.
> 
> Signed-off-by: Hans J. Koch <hjk@linutronix.de>

This doesn't apply cleanly to net-next-2.6, please respin your patch
and resubmit.

Thanks.
