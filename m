From: Joe Perches <joe@perches.com>
Subject: [PATCH 9/9] net/wanrouter: typo fix of faild to failed
Date: Thu, 21 Oct 2010 22:17:20 -0700
Message-ID: <130529f876ab654054274b3a8bf4841714064ea0.1287724261.git.joe@perches.com>
References: <cover.1287724261.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1287724261.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/wanrouter/wanmain.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/wanrouter/wanmain.c b/net/wanrouter/wanmain.c
index 2bf2340..74944a2 100644
--- a/net/wanrouter/wanmain.c
+++ b/net/wanrouter/wanmain.c
@@ -471,7 +471,7 @@ static int wanrouter_device_setup(struct wan_device *wandev,
 		data = vmalloc(conf->data_size);
 		if (!data) {
 			printk(KERN_INFO
-				"%s: ERROR, Faild allocate kernel memory !\n",
+				"%s: ERROR, Failed allocate kernel memory !\n",
 				wandev->name);
 			kfree(conf);
 			return -ENOBUFS;
@@ -481,7 +481,7 @@ static int wanrouter_device_setup(struct wan_device *wandev,
 			err = wandev->setup(wandev, conf);
 		} else {
 			printk(KERN_INFO
-			     "%s: ERROR, Faild to copy from user data !\n",
+			     "%s: ERROR, Failed to copy from user data !\n",
 			       wandev->name);
 			err = -EFAULT;
 		}
-- 
1.7.3.1.g432b3.dirty
