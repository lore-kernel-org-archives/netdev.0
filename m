From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] NFC: llcp: remove bool comparison on device
Date: Wed, 15 Oct 2014 21:01:58 +0200
Message-ID: <1413399718-8382-1-git-send-email-fabf@skynet.be>
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

Fixes coccinelle warning:
net/nfc/llcp_core.c:132:5-11: WARNING: Comparison to bool

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/nfc/llcp_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/llcp_core.c b/net/nfc/llcp_core.c
index 51e7887..978399d 100644
--- a/net/nfc/llcp_core.c
+++ b/net/nfc/llcp_core.c
@@ -129,7 +129,7 @@ static void nfc_llcp_socket_release(struct nfc_llcp_local *local, bool device,
 	write_unlock(&local->sockets.lock);
 
 	/* If we still have a device, we keep the RAW sockets alive */
-	if (device == true)
+	if (device)
 		return;
 
 	write_lock(&local->raw_sockets.lock);
-- 
1.9.3
