From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 33/42] drivers/net/wireless/ath/ath9k: Adjust confusing if
 indentation
Date: Thu, 5 Aug 2010 22:26:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008052226380.31692__46090.5639142313$1281040311$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Sujith Manoharan <Sujith.Manoharan@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:58032 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934222Ab0HEU07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Aug 2010 16:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Outdent the code following the if.

The semantic match that finds this problem is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@r disable braces4@
position p1,p2;
statement S1,S2;
@@

(
if (...) { ... }
|
if (...) S1@p1 S2@p2
)

@script:python@
p1 << r.p1;
p2 << r.p2;
@@

if (p1[0].column == p2[0].column):
  cocci.print_main("branch",p1)
  cocci.print_secs("after",p2)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
This patch doesn't change the semantics of the code.  But it might not be
what is intended.

 drivers/net/wireless/ath/ath9k/ar9003_mac.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
index 5b995be..a462da2 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -185,7 +185,7 @@ static bool ar9003_hw_get_isr(struct ath_hw *ah, enum ath9k_int *masked)
 			ath_print(common, ATH_DBG_INTERRUPT,
 				  "AR_INTR_SYNC_LOCAL_TIMEOUT\n");
 
-			REG_WRITE(ah, AR_INTR_SYNC_CAUSE_CLR, sync_cause);
+		REG_WRITE(ah, AR_INTR_SYNC_CAUSE_CLR, sync_cause);
 		(void) REG_READ(ah, AR_INTR_SYNC_CAUSE_CLR);
 
 	}
