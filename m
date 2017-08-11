From: Colin King <colin.king@canonical.com>
Subject: [PATCH][next] Bluetooth: kfree tmp rather than an alias to it
Date: Fri, 11 Aug 2017 19:33:04 +0100
Message-ID: <20170811183304.17580-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>,
        Gustavo Padovan <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

While the kfree of dhkey_a is of the same address of tmp, it
probably is clearer and more human readable if tmp is kfree'd
rather than dhkey_a.

Detected by CoverityScan, CID#1448650 ("Free of address-of expression")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/bluetooth/selftest.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/selftest.c b/net/bluetooth/selftest.c
index ee92c925ecc5..34a1227f4391 100644
--- a/net/bluetooth/selftest.c
+++ b/net/bluetooth/selftest.c
@@ -164,7 +164,7 @@ static int __init test_ecdh_sample(const u8 priv_a[32], const u8 priv_b[32],
 		ret = -EINVAL;
 
 out:
-	kfree(dhkey_a);
+	kfree(tmp);
 	return ret;
 }
 
-- 
2.11.0
