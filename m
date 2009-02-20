From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCHv3 00/10] convert arm platforms to smsc911x
Date: Fri, 20 Feb 2009 09:19:41 -0800
Message-ID: <20090220171941.GQ7414@atomide.com>
References: <1233075077-17205-1-git-send-email-steve.glendinning@smsc.com> <20090201.003824.20277745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@smsc.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	linux@arm.linux.org.uk, stanley.miao@windriver.com,
	ian.saturley@smsc.com, broonie@opensource.wolfsonmicro.com,
	catalin.marinas@arm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-01-bos.mailhop.org ([63.208.196.178]:64813 "EHLO
	mho-01-bos.mailhop.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752388AbZBTRTv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 12:19:51 -0500
Content-Disposition: inline
In-Reply-To: <20090201.003824.20277745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Miller <davem@davemloft.net> [090201 00:47]:
> From: Steve Glendinning <steve.glendinning@smsc.com>
> Date: Tue, 27 Jan 2009 16:51:08 +0000
> 
> > This patchset, intended for 2.6.30, converts in-tree arm platforms from
> > smc911x to the actively maintained smsc911x driver.
> > 
> > The platform updates (5-7) depend on the driver updates (1-4) for 
> > correct operation, so David Miller is planning to take these via the 
> > net-2.6 tree.  Defconfig updates have been split out (8-10) for merging 
> > via the arm tree.
> 
> I've applied patches 1-4 to net-next-2.6, thanks a lot Steve!

Just for the reference, I'm assuming all the arm related patches will
go via Russell after the net updates are in. So not picking up any of
the omap related patches.

Also turns out I don't even currently have any omap boards with
smc911x/smsc911x on them, they all still have the old smc91x :)

Tony
