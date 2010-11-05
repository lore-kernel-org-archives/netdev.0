From: Joe Perches <joe@perches.com>
Subject: [PATCH 21/49] drivers/net/ehea: Use vzalloc
Date: Thu,  4 Nov 2010 20:07:45 -0700
Message-ID: <488a71bfe20f9bad2440db9b7da18de2650628f0.1288925424.git.joe@perches.com>
References: <alpine.DEB.2.00.1011031108260.11625@router.home>
Cc: Breno Leitao <leitao@linux.vnet.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1011031108260.11625@router.home>
In-Reply-To: <cover.1288925424.git.joe@perches.com>
References: <cover.1288925424.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ehea/ehea_main.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 182b2a7..a84c389 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1496,12 +1496,10 @@ static int ehea_init_q_skba(struct ehea_q_skb_arr *q_skba, int max_q_entries)
 {
 	int arr_size = sizeof(void *) * max_q_entries;
 
-	q_skba->arr = vmalloc(arr_size);
+	q_skba->arr = vzalloc(arr_size);
 	if (!q_skba->arr)
 		return -ENOMEM;
 
-	memset(q_skba->arr, 0, arr_size);
-
 	q_skba->len = max_q_entries;
 	q_skba->index = 0;
 	q_skba->os_skbs = 0;
-- 
1.7.3.1.g432b3.dirty
