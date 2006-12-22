From: David Hollis <dhollis@davehollis.com>
Subject: Re: Generic PHY lib vs. locking
Date: Fri, 22 Dec 2006 10:24:50 -0500
Message-ID: <1166801090.30347.1.camel@dhollis-lnx.sunera.com>
References: <1166760473.6673.85.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Fleming <afleming@freescale.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms040pub.verizon.net ([206.46.252.40]:25469 "EHLO
	vms040pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbWLVQZg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Dec 2006 11:25:36 -0500
Received: from smtp.davehollis.com ([72.64.146.34])
 by vms040.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JAO00BUXLHKXA0M@vms040.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 22 Dec 2006 09:24:57 -0600 (CST)
In-reply-to: <1166760473.6673.85.camel@localhost.localdomain>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-12-22 at 15:07 +1100, Benjamin Herrenschmidt wrote:
> Hi Andy !
> 
> I've been looking at porting various drivers (EMAC, sungem,
> spider_net, ...) to the generic PHY stuff. However, I have one
> significant problem here.
> 

> One solution would be to change it to use a mutex instead of a lock as
> well, though that would change the requirements of where phy_start/stop
> can be called, and use a delayed work queue instead of a timer.

Wouldn't this change also allow it to be used with USB Ethernet devices?
I was looking at porting the asix.c drive to use the PHY layer but the
locking killed that effort since USB devices can't do spinlocks without
hosing things up.

-- 
David Hollis <dhollis@davehollis.com>

