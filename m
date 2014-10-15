From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1 net-next] NFC: digital: remove redundant memory message
Date: Wed, 15 Oct 2014 21:00:49 +0200
Message-ID: <1413399649-8172-1-git-send-email-fabf@skynet.be>
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

Let MM subsystem display out of memory messages.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/nfc/digital_core.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/nfc/digital_core.c b/net/nfc/digital_core.c
index 009bcf3..41ba70c 100644
--- a/net/nfc/digital_core.c
+++ b/net/nfc/digital_core.c
@@ -697,10 +697,8 @@ static int digital_in_send(struct nfc_dev *nfc_dev, struct nfc_target *target,
 	int rc;
 
 	data_exch = kzalloc(sizeof(struct digital_data_exch), GFP_KERNEL);
-	if (!data_exch) {
-		pr_err("Failed to allocate data_exch struct\n");
+	if (!data_exch)
 		return -ENOMEM;
-	}
 
 	data_exch->cb = cb;
 	data_exch->cb_context = cb_context;
-- 
1.9.3
