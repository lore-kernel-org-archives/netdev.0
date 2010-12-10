From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 00/27][pull-request] Intel Wired LAN Driver Updates
Date: Fri, 10 Dec 2010 01:50:40 -0800
Message-ID: <1291974667-30254-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:42532 "EHLO
	qmta08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198Ab0LJJvS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 04:51:18 -0500
To: davem@davemloft.net
To: davem@davemleft.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here are a batch of fixes and cleanups intended for 2.6.38.
The following changes since commit:

commit defb3519a64141608725e2dac5a5aa9a3c644bae
Author: David S. Miller <davem@davemloft.net>
Date:   Wed Dec 8 21:16:57 2010 -0800
  net: Abstract away all dst_entry metrics accesses

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6.git master

Bruce Allan (11):
  e1000e: 82571-based mezzanine card can fail ethtool link test
  e1000e: 82574/82583 performance improvement
  e1000e: 82577/8 must acquire h/w semaphore before workaround
  e1000e: 82571 Serdes can fail to get link
  e1000e: 82577/8/9 mis-configured OEM bits during S0->Sx
  e1000e: 82579 PHY incorrectly identified during init
  e1000e: support new PBA format from EEPROM
  e1000e: prevent null ptr dereference in e1000_tx_queue()
  e1000e: minor error message corrections
  e1000e: static analysis tools complain of a possible null ptr p
    dereference
  e1000e: increment the driver version

Carolyn Wyborny (1):
  igb: Add new function to read part number from EEPROM in string
    format

Dean Nelson (1):
  e1000: fix return value not set on error

Don Skidmore (3):
  ixgbe: fix X540 phy id to correct value
  ixgbe: fix X540 to use it's own info struct
  ixgbe: cleanup string function calls to use bound checking versions.

Emil Tantilov (2):
  ixgb: Don't check for vlan group on transmit
  ixgbe: fix ntuple support

Holger Eitzenberger (1):
  e1000e: fix double initialization in blink path

Jeff Kirsher (8):
  Documentation/networking/e1000.txt: Update documentation
  Documentation/networking/e1000e.txt: Update documentation
  Documentation/networking/igb.txt: update documentation
  Documentation/networking/igbvf.txt: Update documentation
  Documentation/networking/ixgbe.txt: Update ixgbe documentation
  Documentation/networking/ixgbevf.txt: Update documentation
  MAINTAINERS: Update Intel Wired LAN info
  Intel Wired LAN drivers: Use static const

 Documentation/networking/e1000.txt   |   10 +-
 Documentation/networking/e1000e.txt  |   40 ++++---
 Documentation/networking/igb.txt     |   22 +++-
 Documentation/networking/igbvf.txt   |    4 +-
 Documentation/networking/ixgbe.txt   |  211 ++++++++++++++++++++++------------
 Documentation/networking/ixgbevf.txt |    4 -
 MAINTAINERS                          |    2 +
 drivers/net/e1000/e1000_hw.c         |   20 ++--
 drivers/net/e1000/e1000_main.c       |   10 +-
 drivers/net/e1000/e1000_param.c      |   13 +-
 drivers/net/e1000e/82571.c           |   46 ++++++--
 drivers/net/e1000e/defines.h         |    8 +-
 drivers/net/e1000e/e1000.h           |    4 +-
 drivers/net/e1000e/ethtool.c         |   14 ++-
 drivers/net/e1000e/ich8lan.c         |   18 ++-
 drivers/net/e1000e/lib.c             |  135 ++++++++++++++++++----
 drivers/net/e1000e/netdev.c          |   21 ++--
 drivers/net/e1000e/param.c           |    2 +-
 drivers/net/e1000e/phy.c             |   25 +++-
 drivers/net/igb/e1000_defines.h      |    7 +
 drivers/net/igb/e1000_nvm.c          |   93 ++++++++++++++-
 drivers/net/igb/e1000_nvm.h          |    2 +
 drivers/net/igb/e1000_phy.c          |   11 +-
 drivers/net/igb/igb_main.c           |   11 +-
 drivers/net/ixgb/ixgb_main.c         |   51 +++++----
 drivers/net/ixgb/ixgb_param.c        |   21 ++--
 drivers/net/ixgbe/ixgbe_ethtool.c    |   31 +++--
 drivers/net/ixgbe/ixgbe_main.c       |   32 +++---
 drivers/net/ixgbe/ixgbe_phy.c        |    2 +-
 drivers/net/ixgbe/ixgbe_type.h       |    2 +-
 drivers/net/ixgbe/ixgbe_x540.c       |    4 +-
 drivers/net/ixgbevf/ethtool.c        |   18 ++-
 32 files changed, 624 insertions(+), 270 deletions(-)

-- 
1.7.3.2

