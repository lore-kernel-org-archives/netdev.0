From: Divy Le Ray <None@chelsio.com>
Subject: [PATCH 4/10] cxgb3 - bogus status error string
Date: Tue, 30 Jan 2007 19:44:01 -0800
Message-ID: <20070131034401.8607.33239.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:7721 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932597AbXAaDoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jan 2007 22:44:08 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Remove a status error string from the pci-x context 
and add it where it belongs - the pci-e context. 

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/t3_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 4545acb..2215400 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -1181,7 +1181,6 @@ static int t3_handle_intr_status(struct
 static void pci_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info pcix1_intr_info[] = {
-		{ F_PEXERR, "PCI PEX error", -1, 1 },
 		{F_MSTDETPARERR, "PCI master detected parity error", -1, 1},
 		{F_SIGTARABT, "PCI signaled target abort", -1, 1},
 		{F_RCVTARABT, "PCI received target abort", -1, 1},
@@ -1218,6 +1217,7 @@ static void pci_intr_handler(struct adap
 static void pcie_intr_handler(struct adapter *adapter)
 {
 	static const struct intr_info pcie_intr_info[] = {
+		{F_PEXERR, "PCI PEX error", -1, 1},
 		{F_UNXSPLCPLERRR,
 		 "PCI unexpected split completion DMA read error", -1, 1},
 		{F_UNXSPLCPLERRC,
