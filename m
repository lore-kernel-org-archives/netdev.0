From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: convert state_queue work to delayed_work
Date: Fri, 13 Mar 2009 15:41:29 -0700 (PDT)
Message-ID: <20090313.154129.08540488.davem@davemloft.net>
References: <20090306205139.GA30500@joi>
	<20090307104620.7f2aed57@hyperion.delvare>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: marcin.slusarz@gmail.com, netdev@vger.kernel.org,
	afleming@freescale.com, tpiepho@freescale.com,
	linux-kernel@vger.kernel.org
To: khali@linux-fr.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760060AbZCMWln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:41:43 -0400
In-Reply-To: <20090307104620.7f2aed57@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Delvare <khali@linux-fr.org>
Date: Sat, 7 Mar 2009 10:46:20 +0100

> On Fri, 6 Mar 2009 21:51:42 +0100, Marcin Slusarz wrote:
> > It closes a race in phy_stop_machine when reprogramming of phy_timer
> > (from phy_state_machine) happens between del_timer_sync and cancel_work_sync.
> > 
> > Without this change it could lead to crash if phy_device would be freed after
> > phy_stop_machine (timer would fire and schedule freed work).
> > 
> > Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> > Cc: Andy Fleming <afleming@freescale.com>
> > Cc: Trent Piepho <tpiepho@freescale.com>
> > ---
> > 
> > This patch was only compile tested.
> 
> Patch looks good.
> 
> Acked-by: Jean Delvare <khali@linux-fr.org>

Applied, thanks.
