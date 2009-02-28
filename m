From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 0/3] Introduce the Intel 82599 10 Gigabit Network
	Adapter family
Date: Fri, 27 Feb 2009 17:44:16 -0800
Message-ID: <20090228013916.22664.54781.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.emeryville.ca.mail.comcast.net ([76.96.30.80]:57784 "EHLO
	QMTA08.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760150AbZB1Bob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2009 20:44:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series implements basic support for the new Intel 82599 10 Gigabit Network adapter.  Contained in this patchset is:

	1) Hardware specific code to initialize the 82599 device
	2) Include Data Center Bridging support for 82599
	3) Add the current device ID's for 82599, including a fully pluggable 1G/10G SFP+ NIC, and a KX/KX4 mezzanine card

---

PJ Waskiewicz (3):
      ixgbe: Add 82599 device id's, hook it up into the main driver.
      ixgbe: Add DCB for 82599, remove BCN support
      ixgbe: Add hardware specific initialization code for 82599 devices


 drivers/net/ixgbe/Makefile          |    5 
 drivers/net/ixgbe/ixgbe.h           |   29 +
 drivers/net/ixgbe/ixgbe_82598.c     |    7 
 drivers/net/ixgbe/ixgbe_82599.c     | 1277 +++++++++++++++++++++++++++++++++++
 drivers/net/ixgbe/ixgbe_common.c    |  319 +++++++++
 drivers/net/ixgbe/ixgbe_common.h    |   10 
 drivers/net/ixgbe/ixgbe_dcb.c       |   17 
 drivers/net/ixgbe/ixgbe_dcb.h       |   54 +
 drivers/net/ixgbe/ixgbe_dcb_82599.c |  472 +++++++++++++
 drivers/net/ixgbe/ixgbe_dcb_82599.h |  127 +++
 drivers/net/ixgbe/ixgbe_dcb_nl.c    |  193 -----
 drivers/net/ixgbe/ixgbe_ethtool.c   |    3 
 drivers/net/ixgbe/ixgbe_main.c      |  659 +++++++++++++++---
 drivers/net/ixgbe/ixgbe_phy.c       |  590 ++++++++++++++++
 drivers/net/ixgbe/ixgbe_phy.h       |   16 
 drivers/net/ixgbe/ixgbe_type.h      |  766 ++++++++++++++++++++-
 16 files changed, 4131 insertions(+), 413 deletions(-)
 create mode 100644 drivers/net/ixgbe/ixgbe_82599.c
 create mode 100644 drivers/net/ixgbe/ixgbe_dcb_82599.c
 create mode 100644 drivers/net/ixgbe/ixgbe_dcb_82599.h

-- 
Cheers,
Jeff
