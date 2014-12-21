From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: micrel: ksz884x.c:  Remove unused function
Date: Sun, 21 Dec 2014 18:41:38 +0100
Message-ID: <1419183698-10495-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	Andrew Morton <akpm@linux-foundation.org>,
	Wilfried Klaebe <w-lkml@lebenslange-mailadresse.de>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Benoit Taine <benoit.taine@lip6.fr>,
	Julia Lawall <Julia.Lawall@lip6.fr>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	dingtianhong <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:43624 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbaLURiw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Dec 2014 12:38:52 -0500
Received: by mail-wg0-f44.google.com with SMTP id b13so5097055wgh.17
        for <netdev@vger.kernel.org>; Sun, 21 Dec 2014 09:38:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the function port_cfg_dis_learn() that is not used anywhere.

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/micrel/ksz884x.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index f1ebed6c..2fa6ae0 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -2303,12 +2303,6 @@ static inline int port_chk_force_flow_ctrl(struct ksz_hw *hw, int p)
 
 /* Spanning Tree */
 
-static inline void port_cfg_dis_learn(struct ksz_hw *hw, int p, int set)
-{
-	port_cfg(hw, p,
-		KS8842_PORT_CTRL_2_OFFSET, PORT_LEARN_DISABLE, set);
-}
-
 static inline void port_cfg_rx(struct ksz_hw *hw, int p, int set)
 {
 	port_cfg(hw, p,
-- 
1.7.10.4
