From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: x25: remove null checks on arrays calling_ae and called_ae
Date: Thu,  8 Sep 2016 08:42:06 +0100
Message-ID: <20160908074206.13662-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Andrew Hendry <andrew.hendry@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-x25@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

dtefacs.calling_ae and called_ae are both 20 element __u8 arrays and
cannot be null and hence are redundant checks. Remove these.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/x25/af_x25.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/x25/af_x25.c b/net/x25/af_x25.c
index a750f33..f83b74d 100644
--- a/net/x25/af_x25.c
+++ b/net/x25/af_x25.c
@@ -1500,12 +1500,8 @@ out_fac_release:
 			goto out_dtefac_release;
 		if (dtefacs.calling_len > X25_MAX_AE_LEN)
 			goto out_dtefac_release;
-		if (dtefacs.calling_ae == NULL)
-			goto out_dtefac_release;
 		if (dtefacs.called_len > X25_MAX_AE_LEN)
 			goto out_dtefac_release;
-		if (dtefacs.called_ae == NULL)
-			goto out_dtefac_release;
 		x25->dte_facilities = dtefacs;
 		rc = 0;
 out_dtefac_release:
-- 
2.9.3
