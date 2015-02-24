From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 2/8] NFC: NCI: Exporting NFC command and data send API
Date: Tue, 24 Feb 2015 12:01:46 +0200
Message-ID: <1424772112-27399-3-git-send-email-robert.dolca@intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49799 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751627AbbBXKCc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 05:02:32 -0500
In-Reply-To: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nci_send_cmd was exported in order to send commands to the device from
the driver. For the firmware update the driver may use nci_send_data.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 net/nfc/nci/core.c | 1 +
 net/nfc/nci/data.c | 1 +
 2 files changed, 2 insertions(+)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index c4dd5d8..9605b9c 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -1153,6 +1153,7 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 
 	return 0;
 }
+EXPORT_SYMBOL(nci_send_cmd);
 
 /* ---- NCI TX Data worker thread ---- */
 
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 566466d..83acd18 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -203,6 +203,7 @@ free_exit:
 exit:
 	return rc;
 }
+EXPORT_SYMBOL(nci_send_data);
 
 /* ----------------- NCI RX Data ----------------- */
 
-- 
1.9.1
