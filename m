From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] drivers/net/irda/kingsun-sir.c: remove null test before kfree
Date: Tue, 17 Jun 2014 21:22:50 +0200
Message-ID: <1403032970-6471-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix checkpatch warning:
WARNING: kfree(NULL) is safe this check is probably not required

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: netdev@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/irda/kingsun-sir.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-sir.c
index 96fe365..e638893 100644
--- a/drivers/net/irda/kingsun-sir.c
+++ b/drivers/net/irda/kingsun-sir.c
@@ -553,8 +553,8 @@ static int kingsun_probe(struct usb_interface *intf,
 	return 0;
 
 free_mem:
-	if (kingsun->out_buf) kfree(kingsun->out_buf);
-	if (kingsun->in_buf) kfree(kingsun->in_buf);
+	kfree(kingsun->out_buf);
+	kfree(kingsun->in_buf);
 	free_netdev(net);
 err_out1:
 	return ret;
-- 
1.8.4.5
