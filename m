From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Subject: [PATCH 08/18] driver: isdn: capi: remove cast for kmalloc return
 value
Date: Tue, 12 Mar 2013 13:13:47 +0800
Message-ID: <513EB98B.9010400@cn.fujitsu.com>
References: <513EB23D.7020303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Karsten Keil <isdn@linux-pingi.de>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <513EB23D.7020303@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

remove cast for kmalloc return value.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
---
 drivers/isdn/capi/capidrv.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
index 832bc80..cc9f192 100644
--- a/drivers/isdn/capi/capidrv.c
+++ b/drivers/isdn/capi/capidrv.c
@@ -469,8 +469,7 @@ static int capidrv_add_ack(struct capidrv_ncci *nccip,
 {
 	struct ncci_datahandle_queue *n, **pp;
 
-	n = (struct ncci_datahandle_queue *)
-		kmalloc(sizeof(struct ncci_datahandle_queue), GFP_ATOMIC);
+	n = kmalloc(sizeof(struct ncci_datahandle_queue), GFP_ATOMIC);
 	if (!n) {
 		printk(KERN_ERR "capidrv: kmalloc ncci_datahandle failed\n");
 		return -1;
-- 
1.7.1
