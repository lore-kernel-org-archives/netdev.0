From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
 (rmmod BUG)
Date: Fri, 14 Nov 2008 16:21:05 -0800 (PST)
Message-ID: <20081114.162105.193724466.davem@davemloft.net>
References: <20081113.140824.156293734.davem@davemloft.net>
	<1226666324.17392.11.camel@localhost.localdomain>
	<1226688562.12092.8.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752363AbYKOAVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 19:21:06 -0500
In-Reply-To: <1226688562.12092.8.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Fri, 14 Nov 2008 19:49:22 +0100

> On Fri, 2008-11-14 at 13:38 +0100, Jesper Dangaard Brouer wrote:
> > On Thu, 2008-11-13 at 14:08 -0800, David Miller wrote:
> > > I suspect that something might be changing np->num_ldg, but
> > > anyways the following debugging patch should provide some
> > > clues.  Please reproduce this and send the logs it generates.
> > 
> > Debugging the rmmod problem...
> > 
> > I found a strange behavior, rmmod'ing the niu driver will only cause a
> > kernel BUG, if the driver was loaded at boot time.  If I remove the
> > niu.ko driver from /lib/modules/2.6.28-rc4-davem/kernel/drivers/net/
> > reboot the system.  After that I can load and unload the niu.ko driver
> > without problems... hmmm
> 
> Perhaps this is a regression, as the problem is not in v2.6.27.

This is what I started to suspect as well.

> I'll start bisecting monday...
> 
> I'm not sure its a NIU driver bug, as the number of changes to niu.c is
> very small since v2.6.27. (git log v2.6.27.. drivers/net/niu.c)

Ok, let me know what your bisect finds.
