From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/1] bna: remove obsolete use of EXTRA_CFLAGS
Date: Tue,  9 Jun 2015 14:24:43 +0200
Message-ID: <1433852683-1938-1-git-send-email-jslaby@suse.cz>
Cc: rasesh.mody@qlogic.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jslaby@suse.cz>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

EXTRA_CFLAGS should be used on the command line only.

Since EXTRA_CFLAGS here add only a non-existant path to compiler
include paths (by -I), remove EXTRA_CFLAGS completely.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
---
 drivers/net/ethernet/brocade/bna/Makefile | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/Makefile b/drivers/net/ethernet/brocade/bna/Makefile
index 6e10b99733a2..8584abcf5366 100644
--- a/drivers/net/ethernet/brocade/bna/Makefile
+++ b/drivers/net/ethernet/brocade/bna/Makefile
@@ -9,5 +9,3 @@ obj-$(CONFIG_BNA) += bna.o
 bna-objs := bnad.o bnad_ethtool.o bnad_debugfs.o bna_enet.o bna_tx_rx.o
 bna-objs += bfa_msgq.o bfa_ioc.o bfa_ioc_ct.o bfa_cee.o
 bna-objs += cna_fwimg.o
-
-EXTRA_CFLAGS := -Idrivers/net/bna
-- 
2.4.2
