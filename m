From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/4] SMSC LAN75xx USB gigabit ethernet adapter driver
Date: Wed, 10 Mar 2010 18:26:53 +0000
Message-ID: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:48053 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755802Ab0CJS1D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:27:03 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 5942667E27
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:26:57 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds a driver for SMSC's new LAN7500 USB 2.0 to Gigabit
Ethernet controller.

Steve Glendinning (4):
  smsc75xx: SMSC LAN75xx USB gigabit ethernet adapter driver
  smsc75xx: add RX checksum offload
  smsc75xx: add TX checksum offload
  smsc75xx: add TX segmentation offload support

 drivers/net/usb/Kconfig    |    8 +
 drivers/net/usb/Makefile   |    1 +
 drivers/net/usb/smsc75xx.c | 1288 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/smsc75xx.h |  421 +++++++++++++++
 4 files changed, 1718 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/smsc75xx.c
 create mode 100644 drivers/net/usb/smsc75xx.h

