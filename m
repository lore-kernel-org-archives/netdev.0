From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH 06/12] ixgbe: Add SR-IOV specific modules to driver
	Makefile
Date: Tue, 08 Dec 2009 14:14:55 -0800
Message-ID: <20091208221454.28373.78622.stgit@localhost.localdomain>
References: <20091208221258.28373.16663.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.emeryville.ca.mail.comcast.net ([76.96.27.243]:59669
	"EHLO QMTA13.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S966706AbZLHWPF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 17:15:05 -0500
In-Reply-To: <20091208221258.28373.16663.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add the mailbox and SR-IOV feature modules to the ixgbe driver Makefile.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/Makefile |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/Makefile b/drivers/net/ixgbe/Makefile
index 21b41f4..1dd867d 100644
--- a/drivers/net/ixgbe/Makefile
+++ b/drivers/net/ixgbe/Makefile
@@ -33,7 +33,8 @@
 obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
-              ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o
+              ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
+              ixgbe_mbx.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o

