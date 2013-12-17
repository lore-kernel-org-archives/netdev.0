From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] sfc: fix sparse non static symbol warning
Date: Tue, 17 Dec 2013 11:08:10 +0800
Message-ID: <CAPgLHd8gaC5j0Ts7SXdDwFPKNpvm2AR_fxHhT3KSNs2Jsi_Lyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: linux-net-drivers@solarflare.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f45.google.com ([209.85.214.45]:58607 "EHLO
	mail-bk0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab3LQDIL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 22:08:11 -0500
Received: by mail-bk0-f45.google.com with SMTP id mx13so2627950bkb.32
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 19:08:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Fixes the following sparse warning:

drivers/net/ethernet/sfc/falcon.c:2601:6: warning:
 symbol 'falcon_pull_nic_stats' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/sfc/falcon.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/falcon.c b/drivers/net/ethernet/sfc/falcon.c
index 76699f4..1df52db 100644
--- a/drivers/net/ethernet/sfc/falcon.c
+++ b/drivers/net/ethernet/sfc/falcon.c
@@ -2598,7 +2598,7 @@ void falcon_start_nic_stats(struct efx_nic *efx)
 /* We don't acutally pull stats on falcon. Wait 10ms so that
  * they arrive when we call this just after start_stats
  */
-void falcon_pull_nic_stats(struct efx_nic *efx)
+static void falcon_pull_nic_stats(struct efx_nic *efx)
 {
 	msleep(10);
 }
