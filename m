From: Bas Peters <baspeters93@gmail.com>
Subject: [PATCH 2/3] drivers: isdn: isdnloop: isdnloop.c: Fix brace positions according to CodingStyle specifications.
Date: Wed,  4 Feb 2015 23:33:00 +0100
Message-ID: <1423089181-15850-3-git-send-email-baspeters93@gmail.com>
References: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bas Peters <baspeters93@gmail.com>
To: isdn@linux-pingi.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423089181-15850-1-git-send-email-baspeters93@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Signed-off-by: Bas Peters <baspeters93@gmail.com>

---
 drivers/isdn/isdnloop/isdnloop.c | 18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/isdnloop/isdnloop.c b/drivers/isdn/isdnloop/isdnloop.c
index af96317..e4d3620 100644
--- a/drivers/isdn/isdnloop/isdnloop.c
+++ b/drivers/isdn/isdnloop/isdnloop.c
@@ -150,8 +150,7 @@ typedef struct isdnloop_stat {
 	int action;
 } isdnloop_stat;
 /* *INDENT-OFF* */
-static isdnloop_stat isdnloop_stat_table[] =
-{
+static isdnloop_stat isdnloop_stat_table[] = {
 	{"BCON_",          ISDN_STAT_BCONN, 1}, /* B-Channel connected        */
 	{"BDIS_",          ISDN_STAT_BHUP,  2}, /* B-Channel disconnected     */
 	{"DCON_",          ISDN_STAT_DCONN, 0}, /* D-Channel connected        */
@@ -485,8 +484,7 @@ isdnloop_fake(isdnloop_card *card, char *s, int ch)
 	return 0;
 }
 /* *INDENT-OFF* */
-static isdnloop_stat isdnloop_cmd_table[] =
-{
+static isdnloop_stat isdnloop_cmd_table[] = {
 	{"BCON_R",         0,  1},	/* B-Channel connect        */
 	{"BCON_I",         0, 17},	/* B-Channel connect ind    */
 	{"BDIS_R",         0,  2},	/* B-Channel disconnect     */
@@ -527,10 +525,8 @@ isdnloop_fake_err(isdnloop_card *card)
 	isdnloop_fake(card, "NAK", -1);
 }
 
-static u_char ctable_eu[] =
-{0x00, 0x11, 0x01, 0x12};
-static u_char ctable_1t[] =
-{0x00, 0x3b, 0x01, 0x3a};
+static u_char ctable_eu[] = {0x00, 0x11, 0x01, 0x12};
+static u_char ctable_1t[] = {0x00, 0x3b, 0x01, 0x3a};
 
 /*
  * Assemble a simplified cause message depending on the
@@ -649,10 +645,8 @@ isdnloop_kill_ctimer(isdnloop_card *card, int ch)
 	spin_unlock_irqrestore(&card->isdnloop_lock, flags);
 }
 
-static u_char si2bit[] =
-{0, 1, 0, 0, 0, 2, 0, 4, 0, 0};
-static u_char bit2si[] =
-{1, 5, 7};
+static u_char si2bit[] = {0, 1, 0, 0, 0, 2, 0, 4, 0, 0};
+static u_char bit2si[] = {1, 5, 7};
 
 /*
  * Try finding a listener for an outgoing call.
-- 
2.1.0
