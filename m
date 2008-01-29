From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Mon, 28 Jan 2008 18:29:39 -0600
Message-ID: <6D762C47-9C9C-422E-A80E-CC418F624B05@freescale.com>
References: <1199403419.25262.62.camel@localhost.localdomain>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>, Jeff Garzik <jeff@garzik.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57379 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756023AbYA2Aa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2008 19:30:59 -0500
In-Reply-To: <1199403419.25262.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff, Dave, any chance we can get this one in for 2.6.25?  It will  
allow a number of other drivers to start using PHY Lib.
I'm sure Nate can resend if needed.

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


