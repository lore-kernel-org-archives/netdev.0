From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Marvell DSA switch 88E6165 - CPU port in PHY mode
Date: Mon, 12 Mar 2012 09:51:16 +0100
Message-ID: <20120312085116.GC28523@wantstofly.org>
References: <516EEEFC-DEEC-4CF5-BEF6-C5F3F86FCDD5@partychief.com>
 <20120305171224.GU12271@wantstofly.org>
 <3e74a9ae578a434094cbb4036e0423d9@partychief.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: mdsmith@partychief.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61496 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110Ab2CLIvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2012 04:51:19 -0400
Content-Disposition: inline
In-Reply-To: <3e74a9ae578a434094cbb4036e0423d9@partychief.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 08, 2012 at 02:57:57PM +0100, mdsmith@partychief.com wrote:

> >>Hello - have a question about CPU port configuration in the net/dsa
> >>driver code. Can't seem to work out how to bring up the CPU
> >>connected
> >>port on the switch (in our case this is Port 4 hardware strapped
> >>with
> >>its embedded PHY enabled).
> >
> >Hello!  I know of at least a couple of platforms that have a DSA chip
> >connected to the CPU via an MDI type link, but I'm not sure why it's
> >not working for you.  I'd suggest double-checking all the port 5 PHY
> >registers against the chip documentation..
> 
> Hi - perhaps I misunderstood something about the built-in PHY on
> Port 4. We expected to see the PHY enabled in hardware by setting
> logic on the P4_MODE pins. But this doesn't seem to be sufficient as
> I guess one still has to enable the PHY in the driver code (like how
> you do it for the LAN interfaces in net/dsa/slave.c).
> 
> So, after digging through the net/dsa source I found that there is
> nothing explicit in the code to enable the CPU port if it needs a
> PHY. I would like to say that way it is written assumes that it is
> always RGMII so I guess the other platforms you refer to above use
> customized (non-mainline) driver code?

The platform I work on the most configures the CPU PHY port via the
EEPROM and/or handles it in the bootloader (I'm not entirely sure as
I haven't worked on that piece of the system) -- this may work for
you as well.
