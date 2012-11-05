From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] driver: net: ppp: change 8% to %s for seq_printf of pppoe_seq_show
Date: Mon, 05 Nov 2012 19:31:27 +0800
Message-ID: <5097A38F.2000003@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:32741 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751640Ab2KELa0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2012 06:30:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  the length of po->pppoe_pa.dev is 16 (IFNAMSIZ)
  in seq_printf, it is not suitable to use %8s for po->pppoe_pa.dev.
  so change it to %s, since each line has not been solid any more.

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/net/ppp/pppoe.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ppp/pppoe.c b/drivers/net/ppp/pppoe.c
index 20f31d0..7e89710 100644
--- a/drivers/net/ppp/pppoe.c
+++ b/drivers/net/ppp/pppoe.c
@@ -1009,7 +1009,7 @@ static int pppoe_seq_show(struct seq_file *seq,
void *v)
 	po = v;
 	dev_name = po->pppoe_pa.dev;

-	seq_printf(seq, "%08X %pM %8s\n",
+	seq_printf(seq, "%08X %pM %s\n",
 		po->pppoe_pa.sid, po->pppoe_pa.remote, dev_name);
 out:
 	return 0;
-- 
1.7.9.5
