From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net/hsr: fix a warning message
Date: Sat, 21 Nov 2015 13:34:12 +0300
Message-ID: <20151121103412.GF7002@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Arvid Brodin <arvid.brodin@alten.se>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

WARN_ON_ONCE() takes a condition, it doesn't take an error message.  I
have converted this to WARN() instead.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 35a9788..c7d1adc 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -312,7 +312,7 @@ static void send_hsr_supervision_frame(struct hsr_port *master, u8 type)
 	return;
 
 out:
-	WARN_ON_ONCE("HSR: Could not send supervision frame\n");
+	WARN_ONCE(1, "HSR: Could not send supervision frame\n");
 	kfree_skb(skb);
 }
 
