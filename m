From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/8][ATM]: [zatm] eliminate kfree warning (from Tobias Hirning <sskyman@web.de>)
Date: Tue, 19 Jul 2005 16:44:54 -0400
Message-ID: <200507192044.j6JKirFb027183@ginger.cmf.nrl.navy.mil>
Cc: davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6 -- thanks!

[ATM]: [zatm] eliminate kfree warning (from Tobias Hirning <sskyman@web.de>)

  Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>


---
commit 4932248439d20412610ffaade625cbde0e001e37
tree 35a60e3551f5f1abced8a435238575c488041af6
parent 238921d2cb04eb6dcc2ff5914d555d7dcaa4dfc5
author chas williams <chas@relax.(none)> Wed, 06 Jul 2005 13:10:18 -0400
committer chas williams <chas@relax.(none)> Wed, 06 Jul 2005 13:10:18 -0400

 drivers/atm/zatm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c
+++ b/drivers/atm/zatm.c
@@ -1339,7 +1339,7 @@ static int __init zatm_start(struct atm_
 	return 0;
     out:
 	for (i = 0; i < NR_MBX; i++)
-		kfree(zatm_dev->mbx_start[i]);
+		kfree(&zatm_dev->mbx_start[i]);
 	kfree(zatm_dev->rx_map);
 	kfree(zatm_dev->tx_map);
 	free_irq(zatm_dev->irq, dev);
