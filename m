From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 1/3] ssb: add missing method ssb_gige_get_macaddr
Date: Sat, 12 Jan 2013 21:01:43 +0100
Message-ID: <1358020905-9924-2-git-send-email-hauke@hauke-m.de>
References: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	m@bues.ch, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:55490 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754222Ab3ALUHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2013 15:07:50 -0500
In-Reply-To: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_SSB_DRIVER_GIGE is not set the header does not provide the
needed method.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/linux/ssb/ssb_driver_gige.h |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 6b05dcd..1438523 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -175,6 +175,9 @@ static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 {
 	return 0;
 }
+static inline void ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
+{
+}
 
 #endif /* CONFIG_SSB_DRIVER_GIGE */
 #endif /* LINUX_SSB_DRIVER_GIGE_H_ */
-- 
1.7.10.4
