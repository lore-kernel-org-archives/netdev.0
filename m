From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/13] ixgbe: Add SR-IOV specific modules to
	driver Makefile
Date: Sat, 09 Jan 2010 04:26:07 -0800
Message-ID: <20100109122606.4462.84203.stgit@localhost.localdomain>
References: <20100109120719.4462.66489.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:49862 "EHLO
	qmta06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753891Ab0AIM0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2010 07:26:24 -0500
In-Reply-To: <20100109120719.4462.66489.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add the mailbox and SR-IOV feature modules to the ixgbe driver Makefile.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
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

