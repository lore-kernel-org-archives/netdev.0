From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] NFC: llcp: use sizeof(*sdres) instead of nfc_llcp_sdp_tlv
Date: Wed, 15 Oct 2014 21:02:30 +0200
Message-ID: <1413399750-8426-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 See Documentation/CodingStyle Chapter 14

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/nfc/llcp_commands.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/nfc/llcp_commands.c b/net/nfc/llcp_commands.c
index a3ad69a..a450075 100644
--- a/net/nfc/llcp_commands.c
+++ b/net/nfc/llcp_commands.c
@@ -120,7 +120,7 @@ struct nfc_llcp_sdp_tlv *nfc_llcp_build_sdres_tlv(u8 tid, u8 sap)
 	struct nfc_llcp_sdp_tlv *sdres;
 	u8 value[2];
 
-	sdres = kzalloc(sizeof(struct nfc_llcp_sdp_tlv), GFP_KERNEL);
+	sdres = kzalloc(sizeof(*sdres), GFP_KERNEL);
 	if (sdres == NULL)
 		return NULL;
 
@@ -149,7 +149,7 @@ struct nfc_llcp_sdp_tlv *nfc_llcp_build_sdreq_tlv(u8 tid, char *uri,
 
 	pr_debug("uri: %s, len: %zu\n", uri, uri_len);
 
-	sdreq = kzalloc(sizeof(struct nfc_llcp_sdp_tlv), GFP_KERNEL);
+	sdreq = kzalloc(sizeof(*sdreq), GFP_KERNEL);
 	if (sdreq == NULL)
 		return NULL;
 
-- 
1.9.3
