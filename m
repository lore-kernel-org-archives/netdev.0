From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 08:01:14 -0700 (PDT)
Message-ID: <20090312.080114.198232805.davem@davemloft.net>
References: <49B8E6D4.2030702@weinigel.se>
	<20090312.055523.193191701.davem@davemloft.net>
	<49B91A7B.7050303@weinigel.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: christer@weinigel.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45010
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752954AbZCLPB2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 11:01:28 -0400
In-Reply-To: <49B91A7B.7050303@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christer Weinigel <christer@weinigel.se>
Date: Thu, 12 Mar 2009 15:21:47 +0100

> Yes, that why I'd want that in a generic piece of code instead of
> having to hack it into each device driver.  Would a generic command
> line option, something like "ethaddrs=eth0=00:de:ad:be:ef:01" which
> assigns addresses to network cards be acceptable?

Yep, and you can parse that and execute the appropriate
ifconfig command from userspace in your initial ramdisk.
