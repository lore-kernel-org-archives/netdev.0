From: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 3/9] nfc: nci: Introduce new core opcodes
Date: Tue,  1 Sep 2015 17:54:22 +0300
Message-ID: <1441119268-30654-4-git-send-email-robert.dolca@intel.com>
References: <1441119268-30654-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christophe Ricard <christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441119268-30654-1-git-send-email-robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add NCI_OP_CORE_GET_CONFIG_CMD, NCI_OP_CORE_GET_CONFIG_RSP
and NCI_OP_CORE_RESET_NTF.

Signed-off-by: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
