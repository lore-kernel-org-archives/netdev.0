From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1085/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:15:07 +0800
Message-ID: <20160802121507.22460-1-baolex.ni@intel.com>
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, gang.chen.5i5j@gmail.com, mhocko@suse.com,
	koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com
To: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	davem@davemloft.net, jiangshanlai@gmail.com, m.chehab@samsung.com,
	gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/9p/trans_virtio.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
index 4acb1d5..f5ae921 100644
--- a/net/9p/trans_virtio.c
+++ b/net/9p/trans_virtio.c
@@ -527,7 +527,7 @@ static ssize_t p9_mount_tag_show(struct device *dev,
 	return chan->tag_len + 1;
 }
 
-static DEVICE_ATTR(mount_tag, 0444, p9_mount_tag_show, NULL);
+static DEVICE_ATTR(mount_tag, S_IRUSR | S_IRGRP | S_IROTH, p9_mount_tag_show, NULL);
 
 /**
  * p9_virtio_probe - probe for existence of 9P virtio channels
-- 
2.9.2
