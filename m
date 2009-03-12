From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 05:55:23 -0700 (PDT)
Message-ID: <20090312.055523.193191701.davem@davemloft.net>
References: <49B82566.3070909@weinigel.se>
	<20090311171354.04c7a63d@nehalam>
	<49B8E6D4.2030702@weinigel.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: christer@weinigel.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34173
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752114AbZCLMzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 08:55:37 -0400
In-Reply-To: <49B8E6D4.2030702@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christer Weinigel <christer@weinigel.se>
Date: Thu, 12 Mar 2009 11:41:24 +0100

> 1. The bootloader can pass a command line to the kernel and it is saved in non-volatile storage that can be changed from the bootloader
> 
> 2. I can not modify the bootloader
> 
> 3. I can modify the Linux kernel
> 
> 4. The manufacturer has hardcoded a MAC address in the ethernet driver
> 
> 5. I want to use NFS root to make it easy to develop on the platform
> 
> 6. We get a second board so the hardcoded MAC addresses collide

This is getting rediculious.

If you can modify the kernel, you can have the kernel look in the
non-volatile storage for the MAC address and export that information
to the ethernet driver.

Or, you can parse the command line in your platform specific code
and program the MAC address into the chip.

In fact there are many reasonable ways to solve the problem in
your scenerio, and none of them require device driver command
line option handler.

None.
