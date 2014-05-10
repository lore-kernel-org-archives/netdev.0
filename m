From: Randy Dunlap <rdunlap@infradead.org>
Subject: [PATCH] bnx2x: fix build when BNX2X_SRIOV is not enabled
Date: Sat, 10 May 2014 11:33:54 -0700
Message-ID: <536E7112.4080506@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Ariel Elior <ariele@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:55115 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbaEJSd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 May 2014 14:33:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix build when BNX2X_SRIOV is not enabled.
Change one parameter struct from bnx2 to bnx2x and don't return a value
from a void function.

drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:576:48: warning: 'struct bnx2' declared inside parameter list [enabled by default]
drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:576:48: warning: its scope is only this definition or declaration, which is probably not what you want [enabled by default]

drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h:576:60: warning: 'return' with a value, in function returning void [enabled by default]

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc:	Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Found in linux-next and mmotm.

--- mmotm-2014-0509-1617.orig/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
+++ mmotm-2014-0509-1617/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h
@@ -571,7 +571,7 @@ static inline void __iomem *bnx2x_vf_doo
 	return NULL;
 }
 
-static inline void bnx2x_vf_pci_dealloc(struct bnx2 *bp) {return 0; }
+static inline void bnx2x_vf_pci_dealloc(struct bnx2x *bp) {}
 static inline int bnx2x_vf_pci_alloc(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_pf_set_vfs_vlan(struct bnx2x *bp) {}
 static inline int bnx2x_sriov_configure(struct pci_dev *dev, int num_vfs) {return 0; }
