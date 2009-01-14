From: David Miller <davem@davemloft.net>
Subject: Re: New build error - ndo_set_mac_addr
Date: Wed, 14 Jan 2009 14:02:26 -0800 (PST)
Message-ID: <20090114.140226.168294654.davem@davemloft.net>
References: <20090114194746.GL22976@n2100.arm.linux.org.uk>
	<20090114120620.13cf8039@extreme>
	<20090114201907.GA2162@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35552
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759403AbZANWCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 17:02:25 -0500
In-Reply-To: <20090114201907.GA2162@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Wed, 14 Jan 2009 20:19:07 +0000

> On Wed, Jan 14, 2009 at 12:06:20PM -0800, Stephen Hemminger wrote:
> > On Wed, 14 Jan 2009 19:47:46 +0000
> > Russell King - ARM Linux <linux@arm.linux.org.uk> wrote:
> > 
> > > This new build error poped up between rc1-git2 and rc1-git3.
> > > 
> > > drivers/net/arm/etherh.c:649: error: unknown field 'ndo_set_mac_addr' specified in initializer
> > > 
> > > Looks like this should've been ndo_set_mac_address ?
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > Yes, david didn't see the updated version of my patch.
> 
> Do you want me to fix it?  It'll probably be around a week before I ask
> Linus to pull my tree again.

I'll get it fixed in the net-2.6 tree.
