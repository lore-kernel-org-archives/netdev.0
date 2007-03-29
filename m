From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 16/19] e1000: add new chipset-specific files and api files to the Makefile
Date: Thu, 29 Mar 2007 09:40:31 -0700
Message-ID: <20070329164031.6595.74176.stgit@localhost.localdomain>
References: <20070329163304.6595.81963.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: auke-jan.h.kok@intel.com, bruce.w.allan@intel.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	cramerj@intel.com, john.ronciak@intel.com,
	arjan.van.de.ven@intel.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:40281 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030396AbXC2Qko (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 12:40:44 -0400
In-Reply-To: <20070329163304.6595.81963.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeb Cramer <cramerj@intel.com>

Signed-off-by: Jeb Cramer <cramerj@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/Makefile |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000/Makefile b/drivers/net/e1000/Makefile
index 4a6ab15..1086807 100644
--- a/drivers/net/e1000/Makefile
+++ b/drivers/net/e1000/Makefile
@@ -1,7 +1,7 @@
 ################################################################################
 #
 # Intel PRO/1000 Linux driver
-# Copyright(c) 1999 - 2006 Intel Corporation.
+# Copyright(c) 1999 - 2007 Intel Corporation.
 #
 # This program is free software; you can redistribute it and/or modify it
 # under the terms and conditions of the GNU General Public License,
@@ -32,4 +32,18 @@
 
 obj-$(CONFIG_E1000) += e1000.o
 
-e1000-objs := e1000_main.o e1000_hw.o e1000_ethtool.o e1000_param.o
+e1000-objs := e1000_api.o \
+              e1000_82540.o \
+              e1000_82541.o \
+              e1000_82543.o \
+              e1000_82542.o \
+              e1000_82571.o \
+              e1000_ich8lan.o \
+              e1000_80003es2lan.o \
+              e1000_mac.o \
+              e1000_phy.o \
+              e1000_nvm.o \
+              e1000_manage.o \
+              e1000_param.o \
+              e1000_ethtool.o \
+              e1000_main.o
