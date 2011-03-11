From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 00/11][pull request] Intel Wired LAN Driver Updates
Date: Fri, 11 Mar 2011 03:06:19 -0800
Message-ID: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:59823 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754484Ab1CKLGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 06:06:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains FCoE documentation update, ixgb conversion
to the new VLAN model, several fixes and cleanups for e1000e and
the removal of Tx hang detection in ixgbevf (like recent igbvf patch).

The following are changes since commit 1b7fe59322bef9e7a2c05b64a07a66b875299736:
  ipv4: Kill flowi arg to fib_select_multipath()

and are available in the git repository at:
  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master

Bruce Allan (8):
  e1000e: use dev_kfree_skb_irq() instead of dev_kfree_skb()
  e1000e: magic number cleanup - ETH_ALEN
  e1000e: extend timeout for ethtool link test diagnostic
  e1000e: extend EEE LPI timer to prevent dropped link
  e1000e: do not toggle LANPHYPC value bit when PHY reset is blocked
  e1000e: disable jumbo frames on 82579 when MACsec enabled in EEPROM
  e1000e: do not suggest the driver supports Wake-on-ARP
  e1000e: bump version number

Emil Tantilov (1):
  ixgb: convert to new VLAN model

Lior Levy (1):
  ixgbevf: remove Tx hang detection

Yi Zou (1):
  net: add proper documentation for previously added net_device_ops for
    FCoE

 drivers/net/e1000e/defines.h       |    1 +
 drivers/net/e1000e/ethtool.c       |   21 ++++++--------
 drivers/net/e1000e/hw.h            |    5 +--
 drivers/net/e1000e/ich8lan.c       |   45 +++++++++++++++++++++++------
 drivers/net/e1000e/netdev.c        |    6 ++--
 drivers/net/ixgb/ixgb.h            |    2 +-
 drivers/net/ixgb/ixgb_ethtool.c    |   39 ++++++++++++++++++++++++++
 drivers/net/ixgb/ixgb_main.c       |   54 ++++++++----------------------------
 drivers/net/ixgbevf/ixgbevf.h      |    1 -
 drivers/net/ixgbevf/ixgbevf_main.c |   50 ---------------------------------
 include/linux/netdevice.h          |   36 ++++++++++++++++++++++++
 11 files changed, 138 insertions(+), 122 deletions(-)

-- 
1.7.4

