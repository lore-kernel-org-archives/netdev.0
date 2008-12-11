From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 1/9][v2] mISDN: use NULL pointer instead of plain integer
Date: Thu, 11 Dec 2008 22:36:00 +0100
Message-ID: <49419a20.07a0660a.4c25.ffff8ce9@mx.google.com>
Cc: Karsten Keil <kkeil@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f13.google.com ([209.85.218.13]:50613 "EHLO
	mail-bw0-f13.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758632AbYLKXAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2008 18:00:10 -0500
Received: by bwz6 with SMTP id 6so2825019bwz.13
        for <netdev@vger.kernel.org>; Thu, 11 Dec 2008 15:00:08 -0800 (PST)
Cc: linux-kernel@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix more than 100 (all remaining in mISDN) sparse warnings:

  drivers/isdn/hardware/mISDN/hfcmulti.c:***:**: warning: Using plain integer as NULL pointer
  drivers/isdn/mISDN/dsp_tones.c:***:**: warning: Using plain integer as NULL pointer
  drivers/isdn/mISDN/dsp_pipeline.c:***:**: warning: Using plain integer as NULL pointer

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
Acked-by: Karsten Keil <kkeil@suse.de>
---
 drivers/isdn/hardware/mISDN/hfcmulti.c |    2 +-
 drivers/isdn/mISDN/dsp_pipeline.c      |    2 +-
 drivers/isdn/mISDN/dsp_tones.c         |   90 ++++++++++++++++----------------
 3 files changed, 47 insertions(+), 47 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcmulti.c b/drivers/isdn/hardware/mISDN/hfcmulti.c
index 1eac03f..46684e1 100644
--- a/drivers/isdn/hardware/mISDN/hfcmulti.c
+++ b/drivers/isdn/hardware/mISDN/hfcmulti.c
@@ -887,7 +887,7 @@ vpm_echocan_off(struct hfc_multi *hc, int ch)
 static inline void
 hfcmulti_resync(struct hfc_multi *locked, struct hfc_multi *newmaster, int rm)
 {
-	struct hfc_multi *hc, *next, *pcmmaster = 0;
+	struct hfc_multi *hc, *next, *pcmmaster = NULL;
 	u_int *plx_acc_32, pv;
 	u_long flags;
 
diff --git a/drivers/isdn/mISDN/dsp_pipeline.c b/drivers/isdn/mISDN/dsp_pipeline.c
index fdc800b..83639be 100644
--- a/drivers/isdn/mISDN/dsp_pipeline.c
+++ b/drivers/isdn/mISDN/dsp_pipeline.c
@@ -249,7 +249,7 @@ int dsp_pipeline_build(struct dsp_pipeline *pipeline, const char *cfg)
 		name = strsep(&tok, "(");
 		args = strsep(&tok, ")");
 		if (args && !*args)
-			args = 0;
+			args = NULL;
 
 		list_for_each_entry_safe(entry, n, &dsp_elements, list)
 			if (!strcmp(entry->elem->name, name)) {
diff --git a/drivers/isdn/mISDN/dsp_tones.c b/drivers/isdn/mISDN/dsp_tones.c
index 23dd0dd..de4d0c9 100644
--- a/drivers/isdn/mISDN/dsp_tones.c
+++ b/drivers/isdn/mISDN/dsp_tones.c
@@ -238,113 +238,113 @@ struct pattern {
 	u32 seq[10];
 } pattern[] = {
 	{TONE_GERMAN_DIALTONE,
-	{DATA_GA, 0, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GA, 0, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GA, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GA, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{1900, 0, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDDIALTONE,
-	{DATA_GO, 0, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GO, 0, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GO, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{1998, 0, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_DIALTONE,
-	{DATA_DT, 0, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_DT, 0, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_DT, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_DT, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{8000, 0, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_DIALPBX,
-	{DATA_GA, DATA_S, DATA_GA, DATA_S, DATA_GA, DATA_S, 0, 0, 0, 0},
-	{SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, 0, 0, 0, 0},
+	{DATA_GA, DATA_S, DATA_GA, DATA_S, DATA_GA, DATA_S, NULL, NULL, NULL, NULL},
+	{SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL},
 	{2000, 2000, 2000, 2000, 2000, 12000, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDDIALPBX,
-	{DATA_GO, DATA_S, DATA_GO, DATA_S, DATA_GO, DATA_S, 0, 0, 0, 0},
-	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, 0, 0, 0, 0},
+	{DATA_GO, DATA_S, DATA_GO, DATA_S, DATA_GO, DATA_S, NULL, NULL, NULL, NULL},
+	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL},
 	{2000, 2000, 2000, 2000, 2000, 12000, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_DIALPBX,
-	{DATA_DT, DATA_S, DATA_DT, DATA_S, DATA_DT, DATA_S, 0, 0, 0, 0},
-	{SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, 0, 0, 0, 0},
+	{DATA_DT, DATA_S, DATA_DT, DATA_S, DATA_DT, DATA_S, NULL, NULL, NULL, NULL},
+	{SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, SIZE_DT, SIZE_S, NULL, NULL, NULL, NULL},
 	{2000, 2000, 2000, 2000, 2000, 12000, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_RINGING,
-	{DATA_GA, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GA, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GA, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{8000, 32000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDRINGING,
-	{DATA_GO, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GO, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GO, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{8000, 40000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_RINGING,
-	{DATA_RI, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_RI, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_RI, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_RI, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{8000, 32000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_RINGPBX,
-	{DATA_GA, DATA_S, DATA_GA, DATA_S, 0, 0, 0, 0, 0, 0},
-	{SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, 0, 0, 0, 0, 0, 0},
+	{DATA_GA, DATA_S, DATA_GA, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GA, SIZE_S, SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL},
 	{4000, 4000, 4000, 28000, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDRINGPBX,
-	{DATA_GO, DATA_S, DATA_GO, DATA_S, 0, 0, 0, 0, 0, 0},
-	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, 0, 0, 0, 0, 0, 0},
+	{DATA_GO, DATA_S, DATA_GO, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL},
 	{4000, 4000, 4000, 28000, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_RINGPBX,
-	{DATA_RI, DATA_S, DATA_RI, DATA_S, 0, 0, 0, 0, 0, 0},
-	{SIZE_RI, SIZE_S, SIZE_RI, SIZE_S, 0, 0, 0, 0, 0, 0},
+	{DATA_RI, DATA_S, DATA_RI, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_RI, SIZE_S, SIZE_RI, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL},
 	{4000, 4000, 4000, 28000, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_BUSY,
-	{DATA_GA, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GA, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GA, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{4000, 4000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDBUSY,
-	{DATA_GO, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GO, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GO, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{1000, 5000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_BUSY,
-	{DATA_BU, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_BU, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_BU, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_BU, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{4000, 4000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_HANGUP,
-	{DATA_GA, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GA, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GA, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{4000, 4000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_OLDHANGUP,
-	{DATA_GO, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GO, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GO, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{1000, 5000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_AMERICAN_HANGUP,
-	{DATA_DT, 0, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_DT, 0, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_DT, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_DT, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{8000, 0, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_SPECIAL_INFO,
-	{DATA_S1, DATA_S2, DATA_S3, DATA_S, 0, 0, 0, 0, 0, 0},
-	{SIZE_S1, SIZE_S2, SIZE_S3, SIZE_S, 0, 0, 0, 0, 0, 0},
+	{DATA_S1, DATA_S2, DATA_S3, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_S1, SIZE_S2, SIZE_S3, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL},
 	{2666, 2666, 2666, 8002, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_GASSENBESETZT,
-	{DATA_GA, DATA_S, 0, 0, 0, 0, 0, 0, 0, 0},
-	{SIZE_GA, SIZE_S, 0, 0, 0, 0, 0, 0, 0, 0},
+	{DATA_GA, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GA, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{2000, 2000, 0, 0, 0, 0, 0, 0, 0, 0} },
 
 	{TONE_GERMAN_AUFSCHALTTON,
-	{DATA_GO, DATA_S, DATA_GO, DATA_S, 0, 0, 0, 0, 0, 0},
-	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, 0, 0, 0, 0, 0, 0},
+	{DATA_GO, DATA_S, DATA_GO, DATA_S, NULL, NULL, NULL, NULL, NULL, NULL},
+	{SIZE_GO, SIZE_S, SIZE_GO, SIZE_S, NULL, NULL, NULL, NULL, NULL, NULL},
 	{1000, 5000, 1000, 17000, 0, 0, 0, 0, 0, 0} },
 
 	{0,
-	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
-	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
+	{NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
+	{NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL},
 	{0, 0, 0, 0, 0, 0, 0, 0, 0, 0} },
 };
 
@@ -467,7 +467,7 @@ dsp_tone_timeout(void *arg)
 
 	/* set next tone */
 	if (pat->data[index] == DATA_S)
-		dsp_tone_hw_message(dsp, 0, 0);
+		dsp_tone_hw_message(dsp, NULL, 0);
 	else
 		dsp_tone_hw_message(dsp, pat->data[index], *(pat->siz[index]));
 	/* set timer */
-- 
1.5.6.3

