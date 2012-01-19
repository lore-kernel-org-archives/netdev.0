From: Stephane Grosjean <s.grosjean@peak-system.com>
Subject: [PATCH 0/3 V3.1] can/usb: Add PEAK-System PCAN USB adapters driver
Date: Thu, 19 Jan 2012 11:27:40 +0100
Message-ID: <1326968863-20229-1-git-send-email-s.grosjean@peak-system.com>
Cc: linux-usb Mailing List <linux-usb@vger.kernel.org>,
	netdev Mailing List <netdev@vger.kernel.org>,
	linux-can Mailing List <linux-can@vger.kernel.org>,
	Stephane Grosjean <s.grosjean@peak-system.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

That serie of patches adds the peak_usb driver which handles the PCAN-USB
and PCAN-USB Pro adapters from PEAK-System (http://www.peak-system.com).
These patches are planned for kernel v3.02.00 and above.

V3.1: same as V3 + add linux-can in cc:

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

