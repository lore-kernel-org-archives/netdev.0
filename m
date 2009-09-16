From: Sebastian Haas <haas@ems-wuensche.com>
Subject: [PATCH V2 0/2 -next] ems_usb: Added support for EMS CPC-USB/ARM7 CAN
	interface
Date: Wed, 16 Sep 2009 11:04:08 +0200
Message-ID: <20090916090408.12370.94680.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, greg@kroah.com, wg@grandegger.com,
	oliver@hartkopp.net, socketcan-core@lists.berlios.de,
	oliver@neukum.org, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ems-wuensche.com ([81.169.132.244]:32813 "EHLO
	h559305.serverkompetenz.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751784AbZIPJEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 05:04:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series replaces the staging driver cpc-usb with the newly written
ems_usb CAN driver.

---

Sebastian Haas (2):
      ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB interface
      cpc-usb: Removed driver from staging tree


 drivers/net/can/Kconfig               |    7 
 drivers/net/can/Makefile              |    2 
 drivers/net/can/usb/Makefile          |    5 
 drivers/net/can/usb/ems_usb.c         | 1151 ++++++++++++++++++++++++++++++++
 drivers/staging/Kconfig               |    2 
 drivers/staging/Makefile              |    1 
 drivers/staging/cpc-usb/Kconfig       |    4 
 drivers/staging/cpc-usb/Makefile      |    3 
 drivers/staging/cpc-usb/TODO          |    9 
 drivers/staging/cpc-usb/cpc-usb_drv.c | 1185 ---------------------------------
 drivers/staging/cpc-usb/cpc.h         |  440 ------------
 drivers/staging/cpc-usb/cpc_int.h     |   83 --
 drivers/staging/cpc-usb/cpcusb.h      |   86 --
 drivers/staging/cpc-usb/sja2m16c.h    |   41 -
 drivers/staging/cpc-usb/sja2m16c_2.c  |  452 -------------
 15 files changed, 1165 insertions(+), 2306 deletions(-)
 create mode 100644 drivers/net/can/usb/Makefile
 create mode 100644 drivers/net/can/usb/ems_usb.c
 delete mode 100644 drivers/staging/cpc-usb/Kconfig
 delete mode 100644 drivers/staging/cpc-usb/Makefile
 delete mode 100644 drivers/staging/cpc-usb/TODO
 delete mode 100644 drivers/staging/cpc-usb/cpc-usb_drv.c
 delete mode 100644 drivers/staging/cpc-usb/cpc.h
 delete mode 100644 drivers/staging/cpc-usb/cpc_int.h
 delete mode 100644 drivers/staging/cpc-usb/cpcusb.h
 delete mode 100644 drivers/staging/cpc-usb/sja2m16c.h
 delete mode 100644 drivers/staging/cpc-usb/sja2m16c_2.c

-- 
Cheers, Sebastian
-- 
EMS Dr. Thomas Wuensche e.K.
Sonnenhang 3
85304 Ilmmuenster
HRA Neuburg a.d. Donau, HR-Nr. 70.106
Phone: +49-8441-490260
Fax  : +49-8441-81860
http://www.ems-wuensche.com
