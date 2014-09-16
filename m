From: Mark Brown <broonie@kernel.org>
Subject: [PATCH] hostap: proc: Remove unused variable
Date: Tue, 16 Sep 2014 16:16:55 -0700
Message-ID: <1410909415-11661-1-git-send-email-broonie@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linaro-kernel@lists.linaro.org, Mark Brown <broonie@kernel.org>
To: Jouni Malinen <j@w1.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:46385 "EHLO
	mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbaIPXT2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 19:19:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since "hostap: proc: substitute loops by %*phN" (62c5afb8e388) the
variable i has been unused in prism2_bss_list_proc_show() so remove it.

Signed-off-by: Mark Brown <broonie@kernel.org>
---
 drivers/net/wireless/hostap/hostap_proc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wireless/hostap/hostap_proc.c
index 3a23a6d..dd84557 100644
--- a/drivers/net/wireless/hostap/hostap_proc.c
+++ b/drivers/net/wireless/hostap/hostap_proc.c
@@ -168,7 +168,6 @@ static int prism2_bss_list_proc_show(struct seq_file *m, void *v)
 	local_info_t *local = m->private;
 	struct list_head *ptr = v;
 	struct hostap_bss_info *bss;
-	int i;
 
 	if (ptr == &local->bss_list) {
 		seq_printf(m, "#BSSID\tlast_update\tcount\tcapab_info\tSSID(txt)\t"
-- 
2.1.0
