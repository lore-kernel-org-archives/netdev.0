From: Olof Johansson <olof@lixom.net>
Subject: [PATCH v4 0/9] pasemi_mac: fixes and enhancements
Date: Tue, 8 May 2007 00:47:15 -0500
Message-ID: <20070508054715.GA14321@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:32962 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754713AbXEHGIo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2007 02:08:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The nine following patches contain a number of fixes and improvements of
the pasemi_mac driver:

[PATCH v4 1/9] pasemi_mac: Move the IRQ mapping from the PCI layer to the driver
[PATCH v4 2/9] pasemi_mac: Abstract and fix up interrupt restart routines
[PATCH v4 3/9] pasemi_mac: Timer and interrupt fixes
[PATCH v4 4/9] pasemi_mac: Add SKB reuse / copy-break
[PATCH v4 5/9] pasemi_mac: Minor cleanup / define fixes
[PATCH v4 6/9] pasemi_mac: Logic cleanup / rx performance improvements
[PATCH v4 7/9] pasemi_mac: Add msglevel support and "pasemi_mac_debug" module param
[PATCH v4 8/9] pasemi_mac: PHY support
[PATCH v4 9/9] pasemi_mac: Use local-mac-address instead of mac-address if available

Changes since last:

Dropped 1/10 since it's already applied
1/9: refresh due to changes in the arch code
7/9: netif_msg_init() and rename module parameter to "debug".


Thanks,


-Olof
