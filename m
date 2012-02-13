From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/2] bluetooth: logging cleanups and trivial object shrinking
Date: Sun, 12 Feb 2012 19:15:52 -0800
Message-ID: <cover.1329102581.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	linux-bluetooth@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches (2):
  bluetooth: Use more current logging styles
  bluetooth: Convert BT_DBG to pr_debug

 drivers/bluetooth/ath3k.c          |   56 ++++----
 drivers/bluetooth/bcm203x.c        |   34 ++--
 drivers/bluetooth/bfusb.c          |  102 +++++++------
 drivers/bluetooth/bluecard_cs.c    |   17 +-
 drivers/bluetooth/bpa10x.c         |   48 +++---
 drivers/bluetooth/bt3c_cs.c        |   36 +++--
 drivers/bluetooth/btmrvl_debugfs.c |    2 +-
 drivers/bluetooth/btmrvl_main.c    |  102 +++++++------
 drivers/bluetooth/btmrvl_sdio.c    |  149 +++++++++---------
 drivers/bluetooth/btsdio.c         |   26 ++--
 drivers/bluetooth/btuart_cs.c      |   23 ++--
 drivers/bluetooth/btusb.c          |   86 +++++-----
 drivers/bluetooth/btwilink.c       |   46 +++---
 drivers/bluetooth/dtl1_cs.c        |   19 ++-
 drivers/bluetooth/hci_ath.c        |   14 +-
 drivers/bluetooth/hci_bcsp.c       |   78 +++++-----
 drivers/bluetooth/hci_h4.c         |   18 +-
 drivers/bluetooth/hci_ldisc.c      |   37 +++---
 drivers/bluetooth/hci_ll.c         |   83 ++++++-----
 drivers/bluetooth/hci_vhci.c       |    6 +-
 include/net/bluetooth/bluetooth.h  |   10 +-
 include/net/bluetooth/hci_core.h   |    6 +-
 include/net/bluetooth/l2cap.h      |    2 +-
 net/bluetooth/af_bluetooth.c       |   20 ++--
 net/bluetooth/bnep/core.c          |   30 ++--
 net/bluetooth/bnep/netdev.c        |   14 +-
 net/bluetooth/bnep/sock.c          |   10 +-
 net/bluetooth/cmtp/capi.c          |   50 +++---
 net/bluetooth/cmtp/core.c          |   31 ++--
 net/bluetooth/cmtp/sock.c          |   10 +-
 net/bluetooth/hci_conn.c           |   58 ++++----
 net/bluetooth/hci_core.c           |  175 +++++++++++----------
 net/bluetooth/hci_event.c          |  298 ++++++++++++++++++------------------
 net/bluetooth/hci_sock.c           |   26 ++--
 net/bluetooth/hci_sysfs.c          |   10 +-
 net/bluetooth/hidp/core.c          |   58 ++++---
 net/bluetooth/hidp/sock.c          |   10 +-
 net/bluetooth/l2cap_core.c         |  221 ++++++++++++++-------------
 net/bluetooth/l2cap_sock.c         |   40 +++---
 net/bluetooth/lib.c                |   25 +++-
 net/bluetooth/mgmt.c               |   95 ++++++------
 net/bluetooth/rfcomm/core.c        |  180 +++++++++++-----------
 net/bluetooth/rfcomm/sock.c        |   57 ++++----
 net/bluetooth/rfcomm/tty.c         |  106 +++++++-------
 net/bluetooth/sco.c                |   77 +++++-----
 net/bluetooth/smp.c                |   47 +++---
 46 files changed, 1360 insertions(+), 1288 deletions(-)

-- 
1.7.8.111.gad25c.dirty
