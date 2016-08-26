From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next v2] chcr: Fix non static symbol warning
Date: Fri, 26 Aug 2016 14:21:08 +0000
Message-ID: <1472221268-25123-1-git-send-email-weiyj.lk@gmail.com>
References: <1471882278-25777-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-crypto@vger.kernel.org,
        netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Hariprasad Shenai <hariprasad@chelsio.com>,
        Atul Gupta <atul.gupta@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33156 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752864AbcHZOVg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 10:21:36 -0400
In-Reply-To: <1471882278-25777-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/crypto/chelsio/chcr_algo.c:593:5: warning:
 symbol 'cxgb4_is_crypto_q_full' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
v1 -> v2: cc netdev maillist
---
 drivers/crypto/chelsio/chcr_algo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index ad8e353..e4ddb92 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -590,7 +590,7 @@ badkey_err:
 	return -EINVAL;
 }
 
-int cxgb4_is_crypto_q_full(struct net_device *dev, unsigned int idx)
+static int cxgb4_is_crypto_q_full(struct net_device *dev, unsigned int idx)
 {
 	int ret = 0;
 	struct sge_ofld_txq *q;
