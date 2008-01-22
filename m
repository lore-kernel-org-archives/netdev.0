From: David Hollis <dhollis@davehollis.com>
Subject: Re: [PATCH] PHYLIB: Locking fixes for PHY I/O potentially sleeping
Date: Tue, 22 Jan 2008 18:49:24 +0000
Message-ID: <1201027764.5383.11.camel@dhollis-lnx.sunera.com>
References: <1199403419.25262.62.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	netdev <netdev@vger.kernel.org>
To: Nate Case <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms046pub.verizon.net ([206.46.252.46]:46820 "EHLO
	vms046pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbYAVStt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 13:49:49 -0500
Received: from smtp.davehollis.com ([71.180.55.179])
 by vms046.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JV200H1O6YIGRL0@vms046.mailsrvcs.net> for
 netdev@vger.kernel.org; Tue, 22 Jan 2008 12:49:30 -0600 (CST)
In-reply-to: <1199403419.25262.62.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 2008-01-03 at 17:36 -0600, Nate Case wrote:
> 
> PHY read/write functions can potentially sleep (e.g., a PHY accessed
> via I2C).  The following changes were made to account for this:
> 
>     * Change spin locks to mutex locks
>     * Add a BUG_ON() to phy_read() phy_write() to warn against
>       calling them from an interrupt context.
>     * Use work queue for PHY state machine handling since
>       it can potentially sleep
>     * Change phydev lock from spinlock to mutex


Cool, now I think I might be able to use the PAL for USB Ethernet
devices.


-- 
David Hollis <dhollis@davehollis.com>

