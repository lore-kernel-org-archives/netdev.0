From: Joe Perches <joe@perches.com>
Subject: [PATCH next 06/16] drivers/isdn: Use static const char * const where possible
Date: Mon, 13 Sep 2010 21:23:52 -0700
Message-ID: <9a19051e63b3f6c857b08ccd1e0876c604713575.1284435709.git.joe@perches.com>
References: <cover.1284435709.git.joe@perches.com>
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1284435709.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/pcbit/edss1.c |    2 +-
 drivers/isdn/pcbit/edss1.h |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/pcbit/edss1.c b/drivers/isdn/pcbit/edss1.c
index d5920ae..80c9c16 100644
--- a/drivers/isdn/pcbit/edss1.c
+++ b/drivers/isdn/pcbit/edss1.c
@@ -33,7 +33,7 @@
 #include "callbacks.h"
 
 
-char * isdn_state_table[] = {
+const char * const isdn_state_table[] = {
   "Closed",
   "Call initiated",
   "Overlap sending",
diff --git a/drivers/isdn/pcbit/edss1.h b/drivers/isdn/pcbit/edss1.h
index 0b64f97..39f8346 100644
--- a/drivers/isdn/pcbit/edss1.h
+++ b/drivers/isdn/pcbit/edss1.h
@@ -90,7 +90,7 @@ struct fsm_timer_entry {
 	unsigned long timeout;          /* in seconds */
 };
 
-extern char * isdn_state_table[];
+extern const char * const isdn_state_table[];
 
 void pcbit_fsm_event(struct pcbit_dev *, struct pcbit_chan *,
 		     unsigned short event, struct callb_data *);
-- 
1.7.3.rc1
