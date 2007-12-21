From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/8] tg3: Fix supporting flowctrl code
Date: Thu, 20 Dec 2007 20:10:10 -0800 (PST)
Message-ID: <20071220.201010.166363011.davem@davemloft.net>
References: <1198191608.0@teletran1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, andy@greyhouse.net
To: mcarlson@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755566AbXLUEKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:10:11 -0500
In-Reply-To: <1198191608.0@teletran1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Matt Carlson" <mcarlson@broadcom.com>
Date: Thu, 20 Dec 2007 15:00:08 -0800

> This patch does three things.  It modifies tg3_setup_flow_control() to
> use the administrator requested flow control settings if
> autonegotiation is turned off.  It slightly modifies the
> tg3_setup_fiber_mii_phy() function to account for this new use case.
> And finally, it does the same for tg3_setup_copper_phy().
> 
> The copper modifications are more than a small multi-line change.  The
> new code makes an attempt to avoid a link renegotiation if the link is
> active at half duplex and the only difference between the current
> advertised settings and requested advertised settings is the
> flow control advertisements.
> 
> Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
