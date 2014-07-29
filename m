From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 2/9] CAPI: use correct structure type name in sizeof
Date: Tue, 29 Jul 2014 17:16:44 +0200
Message-ID: <1406647011-8543-3-git-send-email-Julia.Lawall@lip6.fr>
References: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-ia64@vger.kernel.org,
	ceph-devel@vger.kernel.org, toralf.foerster@gmx.de, hmh@hmh.eng.br,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406647011-8543-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Correct typo in the name of the type given to sizeof.  Because it is the
size of a pointer that is wanted, the typo has no impact on compilation or
execution.

This problem was found using Coccinelle (http://coccinelle.lip6.fr/).  The
semantic patch used can be found in message 0 of this patch series.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/isdn/capi/capi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index f9a87ed..6a2df32 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -1260,7 +1260,7 @@ static int __init capinc_tty_init(void)
 	if (capi_ttyminors <= 0)
 		capi_ttyminors = CAPINC_NR_PORTS;
 
-	capiminors = kzalloc(sizeof(struct capi_minor *) * capi_ttyminors,
+	capiminors = kzalloc(sizeof(struct capiminor *) * capi_ttyminors,
 			     GFP_KERNEL);
 	if (!capiminors)
 		return -ENOMEM;
