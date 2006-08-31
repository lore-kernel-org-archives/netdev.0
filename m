From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 0/7] 8139cp: misc minor changes
Date: Thu, 31 Aug 2006 22:47:17 +0200
Message-ID: <20060831204717.GA13650@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, Pierre Ossman <drzeus-list@drzeus.cx>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:28322 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S932354AbWHaUsh
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 16:48:37 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The serie contains the patches summarized below:
- 1/7 trim ring_info
- 2/7 remove gratuitous indirection
- 3/7 ring_info removal for the receive path
- 4/7 sync the device private data with its r8169 counterpart
- 5/7 removal of useless BUG_ON() check
- 6/7 pci_get_drvdata(pdev) can not be NULL in suspend handler
- 7/7 use PCI_DEVICE() to shorten the PCI device table

There is nothing critical in the serie as most of its content has
slowly accumulated in various lost branches here. Some testing and
review would be welcome.

The patches are available at:
- git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git 8139cp
- http://www.fr.zoreil.com/linux/kernel/2.6.x/2.6.18-rc5/8139cp

--
Ueimor
