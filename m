From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 0/6] can: remove double include, add support for various PEAK hardare
Date: Sat,  3 Mar 2012 18:00:09 +0100
Message-ID: <1330794015-14930-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:59970 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab2CCRBE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Mar 2012 12:01:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

this patch series targets net-next. The first patch by Danny Kukawka
removes a double include from the cc770 driver. The 5 remaining patches by
Stephane Grosjean add support for various PEAK hardware:
- PCAN-PCIeC (PCI-ExpressCard)
- PCAN-mminiPCI (mini-PCI)
- PCAN-PCI (PCI next-gen)
- PCAN-PC Card (PCMCIA)
- PCAN-USB
- PCAN-USB Pro

Regards, Marc

---

The following changes since commit b4017c5368f992fb8fb3a2545a0977082c6664e4:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2012-03-01 17:57:40 -0500)

are available in the git repository at:

  git://gitorious.org/linux-can/linux-can-next.git master

Danny Kukawka (1):
      can: cc770: linux/can/dev.h included twice

Stephane Grosjean (5):
      can: peak_pci: add support of some new PEAK-System PCI cards
      can: sja1000: add support for PEAK-System PCMCIA card
      can: usb: PEAK-System Technik USB adapters driver core
      can: usb: PEAK-System Technik PCAN-USB specific part
      can: usb: PEAK-System Technik PCAN-USB Pro specific part

 drivers/net/can/cc770/cc770.c                |    1 -
 drivers/net/can/sja1000/Kconfig              |   27 +-
 drivers/net/can/sja1000/Makefile             |    1 +
 drivers/net/can/sja1000/peak_pci.c           |  505 ++++++++++++-
 drivers/net/can/sja1000/peak_pcmcia.c        |  753 +++++++++++++++++++
 drivers/net/can/usb/Kconfig                  |    6 +
 drivers/net/can/usb/Makefile                 |    1 +
 drivers/net/can/usb/peak_usb/Makefile        |    2 +
 drivers/net/can/usb/peak_usb/pcan_usb.c      |  901 ++++++++++++++++++++++
 drivers/net/can/usb/peak_usb/pcan_usb_core.c |  951 +++++++++++++++++++++++
 drivers/net/can/usb/peak_usb/pcan_usb_core.h |  146 ++++
 drivers/net/can/usb/peak_usb/pcan_usb_pro.c  | 1036 ++++++++++++++++++++++++++
 drivers/net/can/usb/peak_usb/pcan_usb_pro.h  |  178 +++++
 13 files changed, 4490 insertions(+), 18 deletions(-)
 create mode 100644 drivers/net/can/sja1000/peak_pcmcia.c
 create mode 100644 drivers/net/can/usb/peak_usb/Makefile
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb.c
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_core.c
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_core.h
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_pro.c
 create mode 100644 drivers/net/can/usb/peak_usb/pcan_usb_pro.h
