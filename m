From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH - resubmit] Fix some #includes in CAN drivers (rebased
 for net-next-2.6)
Date: Tue, 13 Apr 2010 03:33:17 -0700 (PDT)
Message-ID: <20100413.033317.77905087.davem@davemloft.net>
References: <20100413100324.GC2011@bluebox.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	kernel@pengutronix.de, 21cnbao@gmail.com, celston@katalix.com,
	chripell@evolware.org, wg@grandegger.com, haas@ems-wuenche.com,
	per.dalen@gmail.com, P.B.Cheblakov@inp.nsk.su,
	oliver.hartkopp@volkswagen.de, anantgole@ti.com
To: hjk@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46145
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752002Ab0DMKdP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:33:15 -0400
In-Reply-To: <20100413100324.GC2011@bluebox.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hans J. Koch" <hjk@linutronix.de>
Date: Tue, 13 Apr 2010 12:03:25 +0200

> In the current implementation, CAN drivers need to #include <linux/can.h>
> _before_ they #include <linux/can/dev.h>, which is both ugly and
> unnecessary.
> 
> Fix this by including <linux/can.h> in <linux/can/dev.h> and remove the
> #include <linux/can.h> lines from drivers.
> 
> Signed-off-by: Hans J. Koch <hjk@linutronix.de>

Applied, thank you.
