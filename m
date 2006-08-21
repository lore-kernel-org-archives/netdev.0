From: Henne <henne@nachtwindheim.de>
Subject: Linker error on via-velocity driver
Date: Mon, 21 Aug 2006 22:17:03 +0200
Message-ID: <44EA14BF.5090102@nachtwindheim.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server6.greatnet.de ([83.133.96.26]:27111 "EHLO
	server6.greatnet.de") by vger.kernel.org with ESMTP
	id S1750780AbWHUURX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Aug 2006 16:17:23 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi there!

I found a bug in the via-velocity driver, but I cant find a maintainer for that, so I write to the lists.
This driver depends on CONFIG_INET (tcp/ip) if CONFIG_PM is enabled.
This is tested on i386 and x86_64.
I'm not familiar with network stuff but I don't believe a device should depend on a protocol.
If you are interested to fix it:

make allnoconfig
enable CONFIG_PCI
enable CONFIG_NET
enable CONFIG_NET_ETHERNET
enable CONFIG_NET_PCI
enable CONFIG_VIA_VELOCITY
make

That only happens when CONFIG_PM is enabled. If it's switched off it won't happen.

Greets,
Henne

