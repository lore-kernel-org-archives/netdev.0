From: David Hollis <dhollis@davehollis.com>
Subject: Re: phylib usage
Date: Fri, 13 Apr 2007 14:53:10 +0000
Message-ID: <1176475990.3766.3.camel@dhollis-lnx.sunera.com>
References: <1176230461.7526.20.camel@dhollis-lnx.sunera.com>
	<20070410172052.16eae78c.kim.phillips@freescale.com>
	<20070411010356.GC9526@xi.wantstofly.org>
	<20070411164234.2c64bd92.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <buytenh@wantstofly.org>, netdev@vger.kernel.org
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms048pub.verizon.net ([206.46.252.48]:54082 "EHLO
	vms048pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754032AbXDMPEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2007 11:04:44 -0400
Received: from smtp.davehollis.com ([71.251.104.144])
 by vms048.mailsrvcs.net (Sun Java System Messaging Server 6.2-6.01 (built Apr
 3 2006)) with ESMTPA id <0JGF00AS2YVRJQO1@vms048.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 13 Apr 2007 09:57:28 -0500 (CDT)
In-reply-to: <20070411164234.2c64bd92.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-04-11 at 16:42 -0500, Kim Phillips wrote:
> On Wed, 11 Apr 2007 03:03:56 +0200
> Lennert Buytenhek <buytenh@wantstofly.org> wrote:
> 
> > On Tue, Apr 10, 2007 at 05:20:52PM -0500, Kim Phillips wrote:
> > 
> > > (note I'm coming from an embedded world here.)
> > 
> > Please read this:
> > 
> > 	http://marc.info/?l=linux-netdev&m=116527863300952&w=2
> 
> Not sure how to interpret that.  My point was I don't see as much PHY variation in non-embedded applications.
> 
> Kim

There may not be as much, but there definitely are still cases where
there are devices that may have one of three or four different PHYs.
I'm not in the embedded world, but while I know that there are
differences, it isn't THAT different that something as potentially
useful as PHY abstraction wouldn't be useful for regular PCI/USB network
interfaces.

Or are there too many cases where NIC x needs to do these fiddlings with
PHY y, where as NIC z has to do different fiddlings with PHY y?

Again, I don't have a lot of experience with Ethernet devices but in
looking at a lot of the different driver code, it looks like they all
fiddle with the PHYs in basically the same way, though some drivers do
more, some less.  Most likely due to lack of access to errata and such
or issues just not cropping up that need to be fixed.

-- 
David Hollis <dhollis@davehollis.com>

