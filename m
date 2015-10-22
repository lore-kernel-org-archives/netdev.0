From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 03/10] nfc: nci: Introduce new core opcodes
Date: Thu, 22 Oct 2015 12:11:35 +0300
Message-ID: <1445505102-16639-4-git-send-email-robert.dolca@intel.com>
References: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add NCI_OP_CORE_GET_CONFIG_CMD, NCI_OP_CORE_GET_CONFIG_RSP
and NCI_OP_CORE_RESET_NTF.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 include/net/nfc/nci.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/net/nfc/nci.h b/include/net/nfc/nci.h
index 75d2e18..b495825 100644
--- a/include/net/nfc/nci.h
+++ b/include/net/nfc/nci.h
@@ -315,6 +315,8 @@ struct nci_nfcee_mode_set_cmd {
 	__u8	nfcee_mode;
 } __packed;
 
+#define NCI_OP_CORE_GET_CONFIG_CMD	nci_opcode_pack(NCI_GID_CORE, 0x03)
+
 /* ----------------------- */
 /* ---- NCI Responses ---- */
 /* ----------------------- */
@@ -375,6 +377,9 @@ struct nci_nfcee_discover_rsp {
 } __packed;
 
 #define NCI_OP_NFCEE_MODE_SET_RSP nci_opcode_pack(NCI_GID_NFCEE_MGMT, 0x01)
+
+#define NCI_OP_CORE_GET_CONFIG_RSP	nci_opcode_pack(NCI_GID_CORE, 0x03)
+
 /* --------------------------- */
 /* ---- NCI Notifications ---- */
 /* --------------------------- */
@@ -528,4 +533,6 @@ struct nci_nfcee_discover_ntf {
 	struct nci_nfcee_information_tlv	information_tlv;
 } __packed;
 
+#define NCI_OP_CORE_RESET_NTF		nci_opcode_pack(NCI_GID_CORE, 0x00)
+
 #endif /* __NCI_H */
-- 
1.9.1
