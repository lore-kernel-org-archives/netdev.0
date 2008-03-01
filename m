From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] atm/idt77252.c: make 2 functions static
Date: Sat, 1 Mar 2008 18:23:13 +0200
Message-ID: <20080301162313.GZ25835@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chas@cmf.nrl.navy.mil, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:55880 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762477AbYCAQYj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 1 Mar 2008 11:24:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the following needlessly global functions static:
- idt77252_send()
- idt77252_dev_close()

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/atm/idt77252.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

36dff5da01d6548a345e7d9a115ee3121df95591 foobar
diff --git a/drivers/atm/idt77252.c b/drivers/atm/idt77252.c
index eee54c0..9e94b64 100644
--- a/drivers/atm/idt77252.c
+++ b/drivers/atm/idt77252.c
@@ -2016,8 +2016,7 @@ idt77252_send_skb(struct atm_vcc *vcc, struct sk_buff *skb, int oam)
 	return 0;
 }
 
-int
-idt77252_send(struct atm_vcc *vcc, struct sk_buff *skb)
+static int idt77252_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	return idt77252_send_skb(vcc, skb, 0);
 }
@@ -3072,8 +3071,7 @@ idt77252_dev_open(struct idt77252_dev *card)
 	return 0;
 }
 
-void
-idt77252_dev_close(struct atm_dev *dev)
+static void idt77252_dev_close(struct atm_dev *dev)
 {
 	struct idt77252_dev *card = dev->dev_data;
 	u32 conf;

