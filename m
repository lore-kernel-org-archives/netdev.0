From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 0/4] atl1: Attansic L1 ethernet driver
Date: Sun, 21 Jan 2007 15:04:16 -0600
Message-ID: <20070121210416.GA2702@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, csnook@redhat.com, hch@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf16aec.mail.bellsouth.net ([205.152.59.64]:57623 "EHLO
	imf16aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751591AbXAUVEW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 16:04:22 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This is the latest submittal of the patchset providing support for the 
Attansic L1 gigabit ethernet adapter.  This patchset is built against 
kernel version 2.6.20-rc5.

This version incorporates all comments from:

Christoph Hellwig:
http://lkml.org/lkml/2007/1/11/43
http://lkml.org/lkml/2007/1/11/45
http://lkml.org/lkml/2007/1/11/48
http://lkml.org/lkml/2007/1/11/49

Jeff Garzik:
http://lkml.org/lkml/2007/1/18/233

Many thanks to both for reviewing the driver.

The monolithic version of this patchset may be found at:
ftp://hogchain.net/pub/linux/attansic/kernel_driver/atl1-2.0.5-linux-2.6.20.rc5.patch.bz2

As a reminder, this driver is a modified version of the Attansic reference 
driver for the L1 ethernet adapter.  Attansic has granted permission for 
its inclusion in the mainline kernel.

This patchset contains:

drivers/net/Kconfig             |   11 +
drivers/net/Makefile            |    1 +
drivers/net/atl1/Makefile       |    2 +
drivers/net/atl1/atl1.h         |  288 +++++
drivers/net/atl1/atl1_ethtool.c |  436 +++++++
drivers/net/atl1/atl1_hw.c      |  728 ++++++++++++
drivers/net/atl1/atl1_hw.h      |  965 +++++++++++++++
drivers/net/atl1/atl1_main.c    | 2490 ++++++++++++++++++++++++++++++++++++++++
drivers/net/atl1/atl1_param.c   |  223 ++++
9 files changed, 5144 insertions(+), 0 deletions(-)

