From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 0/3] bluetooth: Shrink object size, use current logging style
Date: Thu, 16 Feb 2012 23:32:41 -0800
Message-ID: <cover.1329461202.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
	"Gustavo F. Padovan" <padovan@profusion.mobi>,
	linux-bluetooth@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:39580 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751143Ab2BQHdQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Feb 2012 02:33:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save some small amount of text and use more common logging styles.

V2:
Separate the logging function patch from the BT_INFO/BT_ERR macro conversion.
At some point, the BT_INFO/BT_ERR/BT_DBG macros could be removed.

Joe Perches (3):
  bluetooth: Add logging functions bt_info and bt_err
  bluetooth: Convert BT_ERR/BT_INFO to bt_err/bt_info
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
 include/net/bluetooth/bluetooth.h  |   14 +-
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
 net/bluetooth/lib.c                |   27 +++-
 net/bluetooth/mgmt.c               |   95 ++++++------
 net/bluetooth/rfcomm/core.c        |  180 +++++++++++-----------
 net/bluetooth/rfcomm/sock.c        |   57 ++++----
 net/bluetooth/rfcomm/tty.c         |  106 +++++++-------
 net/bluetooth/sco.c                |   77 +++++-----
 net/bluetooth/smp.c                |   47 +++---
 46 files changed, 1366 insertions(+), 1288 deletions(-)

-- 
1.7.8.111.gad25c.dirty
