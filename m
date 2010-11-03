From: Sjur Braendeland <sjur.brandeland@stericsson.com>
Subject: [PATCH] caif: Remove noisy printout when disconnecting caif socket
Date: Wed, 03 Nov 2010 21:19:25 +0100
Message-ID: <1288815565-2616-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:34302 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754179Ab0KCUTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Nov 2010 16:19:30 -0400
Received: from ignis-smin.broadpark.no ([80.202.8.11])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LBB00FYYSGGN350@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Wed, 03 Nov 2010 21:19:28 +0100 (CET)
Received: from localhost.localdomain ([80.203.143.37])
 by ignis-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LBB00H70SGF3F50@ignis-smin.broadpark.no> for
 netdev@vger.kernel.org; Wed, 03 Nov 2010 21:19:28 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>
---
 net/caif/cfctrl.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/caif/cfctrl.c b/net/caif/cfctrl.c
index 08f267a..3cd8f97 100644
--- a/net/caif/cfctrl.c
+++ b/net/caif/cfctrl.c
@@ -361,11 +361,10 @@ void cfctrl_cancel_req(struct cflayer *layr, stru=
ct cflayer *adap_layer)
 	struct cfctrl_request_info *p, *tmp;
 	struct cfctrl *ctrl =3D container_obj(layr);
 	spin_lock(&ctrl->info_list_lock);
-	pr_warn("enter\n");
=20
 	list_for_each_entry_safe(p, tmp, &ctrl->list, list) {
 		if (p->client_layer =3D=3D adap_layer) {
-			pr_warn("cancel req :%d\n", p->sequence_no);
+			pr_debug("cancel req :%d\n", p->sequence_no);
 			list_del(&p->list);
 			kfree(p);
 		}
--=20
1.6.3.3

