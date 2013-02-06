From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 2/4] ssb: add missing method ssb_gige_get_macaddr
Date: Wed,  6 Feb 2013 18:14:12 +0100
Message-ID: <1360170854-32029-3-git-send-email-hauke@hauke-m.de>
References: <1360170854-32029-1-git-send-email-hauke@hauke-m.de>
Cc: mcarlson@broadcom.com, mchan@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:35146 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756035Ab3BFROj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 12:14:39 -0500
In-Reply-To: <1360170854-32029-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_SSB_DRIVER_GIGE is not set the header does not provide the
needed method.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 include/linux/ssb/ssb_driver_gige.h |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/ssb/ssb_driver_gige.h b/include/linux/ssb/ssb_driver_gige.h
index 912af3c..86a12b0 100644
--- a/include/linux/ssb/ssb_driver_gige.h
+++ b/include/linux/ssb/ssb_driver_gige.h
@@ -170,6 +170,10 @@ static inline bool ssb_gige_must_flush_posted_writes(struct pci_dev *pdev)
 {
 	return 0;
 }
+static inline int ssb_gige_get_macaddr(struct pci_dev *pdev, u8 *macaddr)
+{
+	return -ENODEV;
+}
 
 #endif /* CONFIG_SSB_DRIVER_GIGE */
 #endif /* LINUX_SSB_DRIVER_GIGE_H_ */
-- 
1.7.10.4
