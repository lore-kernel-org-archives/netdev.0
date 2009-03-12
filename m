From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 10:43:45 -0700 (PDT)
Message-ID: <20090312.104345.68580544.davem@davemloft.net>
References: <49B91A7B.7050303@weinigel.se>
	<20090312151211.GB24995@hmsreliant.think-freely.org>
	<49B93777.7030202@weinigel.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: christer@weinigel.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751587AbZCLRn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 13:43:59 -0400
In-Reply-To: <49B93777.7030202@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christer Weinigel <christer@weinigel.se>
Date: Thu, 12 Mar 2009 17:25:27 +0100

> In theory, nothing.  In practice, well, where do I find an example
> initrd that I can build on that has a DHCP client that hands over
> the NFS root information from the DHCP response to a tool that
> mounts the NFS root file system?  So far I haven't seen anything
> like that and the infrastructure to build initrds (such as klibc) is
> still hard to find and use.  Every time I've tried to build an
> initrd that can do DCHP+NFS root it has turned out to be too much
> trouble and I've had to drop it as deadlines come closer.

Just about every single distribution has to build a initrd
that has to be able to setup a network, and have the necessary
infrastructure to access things over NFS in order to implement
their installer.

You can start with the debian installer, that's probably the
easiest to hack on and extend.

Or you can just continue to list excuses, that might be easier.
