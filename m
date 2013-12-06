From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: [net-next PATCH v3 3/6] macvtap: remove the dead branch
Date: Fri,  6 Dec 2013 14:19:39 +0800
Message-ID: <1386310782-9378-4-git-send-email-zwu.kernel@gmail.com>
References: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386310782-9378-1-git-send-email-zwu.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>

Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
---
 drivers/net/macvtap.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 9093004..d271fb4 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -779,8 +779,6 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 			return -EINVAL;
 
 		ret = macvtap_skb_to_vnet_hdr(skb, &vnet_hdr);
-		if (ret)
-			return ret;
 
 		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
 			return -EFAULT;
-- 
1.7.6.5
