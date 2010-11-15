From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 00/11] Remove unnecessary casts of pci_get_drvdata
Date: Mon, 15 Nov 2010 12:13:51 -0800
Message-ID: <cover.1289851770.git.joe@perches.com>
Cc: linux-i2c-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-ide-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	alsa-devel-K7yf7f+aM1XWsZ/bQMPhNw@public.gmane.org
To: Jiri Kosina <trivial-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-i2c-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Joe Perches (11):
  drivers/i2c/busses/i2c-nforce2.c: Remove unnecessary casts of pci_get_drvdata
  drivers/ide/pmac.c: Remove unnecessary casts of pci_get_drvdata
  drivers/media/dvb/ngene/ngene-core.c: Remove unnecessary casts of pci_get_drvdata
  drivers/misc/ibmasm/module.c: Remove unnecessary casts of pci_get_drvdata
  drivers/net/irda: Remove unnecessary casts of pci_get_drvdata
  drivers/net/s2io.c: Remove unnecessary casts of pci_get_drvdata
  drivers/net/vxge/vxge-main.c: Remove unnecessary casts of pci_get_drvdata
  drivers/scsi/be2iscsi/be_main.c: Remove unnecessary casts of pci_get_drvdata
  drivers/staging: Remove unnecessary casts of pci_get_drvdata
  drivers/usb/host/uhci-hcd.c: Remove unnecessary casts of pci_get_drvdata
  sound/pci/asihpi/hpioctl.c: Remove unnecessary casts of pci_get_drvdata

 drivers/i2c/busses/i2c-nforce2.c          |    2 +-
 drivers/ide/pmac.c                        |    4 ++--
 drivers/media/dvb/ngene/ngene-core.c      |    2 +-
 drivers/misc/ibmasm/module.c              |    2 +-
 drivers/net/irda/donauboe.c               |    6 +++---
 drivers/net/irda/vlsi_ir.c                |    2 +-
 drivers/net/s2io.c                        |    3 +--
 drivers/net/vxge/vxge-main.c              |   28 ++++++++++++----------------
 drivers/scsi/be2iscsi/be_main.c           |    2 +-
 drivers/staging/crystalhd/crystalhd_lnx.c |    6 +++---
 drivers/staging/et131x/et131x_initpci.c   |    2 +-
 drivers/staging/wlags49_h2/wl_pci.c       |    2 +-
 drivers/usb/host/uhci-hcd.c               |    2 +-
 sound/pci/asihpi/hpioctl.c                |    2 +-
 14 files changed, 30 insertions(+), 35 deletions(-)

-- 
1.7.3.1.g432b3.dirty
