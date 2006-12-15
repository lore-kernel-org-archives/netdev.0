From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 09/14] e1000: fix ethtool reported bus type for older
	adapters
Date: Fri, 15 Dec 2006 10:37:32 +0100
Message-ID: <1166175452.3365.127.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751473AbWLOKAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:52 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9guY4006174
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:56 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9gug0006171
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:56 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: fix ethtool reported bus type for older adapters
From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

For older adapters we know that they are of the PCI bus type, so we can
just set this.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/drivers/net/e1000/e1000_hw.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_hw.c
+++ linux-2.6/drivers/net/e1000/e1000_hw.c
@@ -6575,7 +6575,7 @@ e1000_get_bus_info(struct e1000_hw *hw)
     switch (hw->mac_type) {
     case e1000_82542_rev2_0:
     case e1000_82542_rev2_1:
-        hw->bus_type = e1000_bus_type_unknown;
+        hw->bus_type = e1000_bus_type_pci;
         hw->bus_speed = e1000_bus_speed_unknown;
         hw->bus_width = e1000_bus_width_unknown;
         break;

