From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 3/3][ATM]: [zatm] always *pcr in alloc_shaper()
Date: Sun, 01 Oct 2006 11:18:00 -0400
Message-ID: <200610011518.k91FI070006399@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:48273 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S1750955AbWJAPSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Oct 2006 11:18:14 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [zatm] always *pcr in alloc_shaper()

Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit ae0e261f74750f57c963349f5c09c8057d5eee32
tree 5e9358ef3fd7d00e3be7a1862afa62a6852c8cb6
parent d7b1207f84d681df2e46c6f22ca153eb7f0944cb
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sun, 01 Oct 2006 11:14:19 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sun, 01 Oct 2006 11:14:19 -0400

 drivers/atm/zatm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
index c491ec4..083c5d3 100644
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -800,6 +800,7 @@ static int alloc_shaper(struct atm_dev *
 		i = m = 1;
 		zatm_dev->ubr_ref_cnt++;
 		zatm_dev->ubr = shaper;
+		*pcr = 0;
 	}
 	else {
 		if (min) {
