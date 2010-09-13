From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/25] drivers/isdn: Use static const char arrays
Date: Mon, 13 Sep 2010 12:47:44 -0700
Message-ID: <0456ee44384064d43253cf1b0837f88e318bddf2.1284406638.git.joe@perches.com>
References: <cover.1284406638.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1875 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755166Ab0IMTsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Sep 2010 15:48:25 -0400
In-Reply-To: <cover.1284406638.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/hysdn/hycapi.c  |    2 +-
 drivers/isdn/mISDN/dsp_cmx.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 6299b06..5de3a93 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -151,7 +151,7 @@ static void
 hycapi_register_internal(struct capi_ctr *ctrl, __u16 appl,
 			 capi_register_params *rp)
 {
-	char ExtFeatureDefaults[] = "49  /0/0/0/0,*/1,*/2,*/3,*/4,*/5,*/6,*/7,*/8,*/9,*";
+	static const char ExtFeatureDefaults[] = "49  /0/0/0/0,*/1,*/2,*/3,*/4,*/5,*/6,*/7,*/8,*/9,*";
 	hycapictrl_info *cinfo = (hycapictrl_info *)(ctrl->driverdata);
 	hysdn_card *card = cinfo->card;
 	struct sk_buff *skb;
diff --git a/drivers/isdn/mISDN/dsp_cmx.c b/drivers/isdn/mISDN/dsp_cmx.c
index 76d9e67..3d80990 100644
--- a/drivers/isdn/mISDN/dsp_cmx.c
+++ b/drivers/isdn/mISDN/dsp_cmx.c
@@ -1155,7 +1155,7 @@ int delaycount;
 static void
 showdelay(struct dsp *dsp, int samples, int delay)
 {
-	char bar[] = "--------------------------------------------------|";
+	static const char bar[] = "--------------------------------------------------|";
 	int sdelay;
 
 	delaycount += samples;
-- 
1.7.3.rc1

