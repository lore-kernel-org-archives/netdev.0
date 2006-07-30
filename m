From: maximilian attems <maks@sternwelten.at>
Subject: Re: Bug#380411: 3c59x broken after swsuspend
Date: Sun, 30 Jul 2006 11:25:12 +0200
Message-ID: <20060730092512.GH8147@nancy>
References: <20060730002718.GA13889@nighthawk.chemicalconnection.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from baikonur.stro.at ([213.239.196.228]:25731 "EHLO
	baikonur.stro.at") by vger.kernel.org with ESMTP id S932125AbWG3JZQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jul 2006 05:25:16 -0400
To: Michael Banck <mbanck@debian.org>, 380411@bugs.debian.org
Content-Disposition: inline
In-Reply-To: <20060730002718.GA13889@nighthawk.chemicalconnection.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

hello michael,

sending bugreport to netdev.

On Sun, 30 Jul 2006, Michael Banck wrote:

> Package: linux-2.6
> Version: 2.6.17-4
> 
> after hibernate, my 3Com Corporation 3c556 Hurricane CardBus [Cyclone]
> (rev 10) (3c59x driver) fails to come back up.
> 
> This is written on the console/xterm:
> 
> Internet Systems Consortium DHCP Client V3.0.4
> Copyright 2004-2006 Internet Systems Consortium.
> All rights reserved.
> For info, please visit http://www.isc.org/sw/dhcp/
> 
> SIOCSIFADDR: No such device
> eth0: ERROR while getting interface flags: No such device
> eth0: ERROR while getting interface flags: No such device
> FATAL: Module acpi_sbs not found.
> Bind socket to interface: No such device
> Failed to bring up eth0.
> 
> And this is in dmesg:
> 
> 3c59x: Donald Becker and others. www.scyld.com/network/vortex.html
> 0000:00:0b.0: 3Com PCI 3c556 Laptop Tornado at c8830400.
> eth1: New link status: Connected (0001)
> *** EEPROM MAC address is invalid.
> 3c59x: vortex_probe1 fails.  Returns -22
> ACPI: PCI interrupt for device 0000:00:0b.0 disabled
> 3c59x: probe of 0000:00:0b.0 failed with error -22
> 
> 
> Michael
-- 
maks
