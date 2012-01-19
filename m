From: Stephane Grosjean <s.grosjean@peak-system.com>
Subject: [PATCH 0/3 V3] can/usb: Add PEAK-System PCAN USB adapters driver
Date: Thu, 19 Jan 2012 11:17:37 +0100
Message-ID: <1326968260-20082-1-git-send-email-s.grosjean@peak-system.com>
Cc: linux-usb Mailing List <linux-usb@vger.kernel.org>,
	netdev Mailing List <netdev@vger.kernel.org>,
	Stephane Grosjean <s.grosjean@peak-system.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from delay-2d.bbox.fr ([194.158.122.62]:60704 "EHLO delay-2d.bbox.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752768Ab2ASKjW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jan 2012 05:39:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That serie of patches adds the peak_usb driver which handles the PCAN-USB
and PCAN-USB Pro adapters from PEAK-System (http://www.peak-system.com).
These patches are planned for kernel v3.02.00 and above.

Stephane Grosjean (3):
  can/usb: PEAK-System Technik USB adapters driver core
  can/usb: PEAK-System Technik PCAN-USB specific part
  can/usb: PEAK-System Technik PCAN-USB Pro specific part

 drivers/net/can/usb/Kconfig                  |    6 +
 drivers/net/can/usb/Makefile                 |    1 +
 drivers/net/can/usb/peak_usb/Makefile        |    2 +
 drivers/net/can/usb/peak_usb/pcan_usb.c      |  746 ++++++++++++++++++++
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |  875 ++++++++++++++++++++++++
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |  138 ++++
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  |  943 ++++++++++++++++++++++++++
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h  |  178 +++++
 8 files changed, 2889 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/can/usb/peak_usb/Makefile
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb.c
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_core.c
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_core.h
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_pro.c
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_pro.h
