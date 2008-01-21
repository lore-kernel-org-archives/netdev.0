From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Mon, 21 Jan 2008 14:05:15 -0600
Message-ID: <BA72E4CF-51D0-40D5-904C-B54C7C67C324@freescale.com>
References: <1199403419.25262.62.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:50698 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbYAUUFn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 15:05:43 -0500
In-Reply-To: <1199403419.25262.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 3, 2008, at 17:36, Nate Case wrote:

> PHY read/write functions can potentially sleep (e.g., a PHY accessed
> via I2C).  The following changes were made to account for this:
>
>     * Change spin locks to mutex locks
>     * Add a BUG_ON() to phy_read() phy_write() to warn against
>       calling them from an interrupt context.
>     * Use work queue for PHY state machine handling since
>       it can potentially sleep
>     * Change phydev lock from spinlock to mutex
>
> Signed-off-by: Nate Case <ncase@xes-inc.com>


Ok, I've tested this on my system and it works.

Acked-by: Andy Fleming <afleming@freescale.com>
