From: olof@lixom.net (Olof Johansson)
Subject: [PATCH v3] [0/10] pasemi_mac: fixes and enhancements
Date: Sat, 28 Apr 2007 15:36:24 -0500
Message-ID: <20070428203624.GA4331@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:38596 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750719AbXD1Ufr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 16:35:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The following patch set contains a number of fixes and improvements of
the pasemi_mac driver:

1/10: A couple of minor bugfixes.
2/10: Move the IRQ mapping from the PCI layer under our platform, to
     the driver.
3/10: Abstract and fix up interrupt restart routines
4/10: Timer and interrupt fixes
5/10: Add SKB reuse / copy-break
6/10: Minor cleanup / define fixes
7/10: Logic cleanup / rx performance improvements
8/10: Add msglevel support and "pasemi_mac_debug" module param
9/10: PHY support
10/10: Use local-mac-address instead of mac-address if available.


-Olof
