From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 16/17] Tools: hv: Get rid of some unused variables
Date: Tue, 24 Jul 2012 09:01:40 -0700
Message-ID: <1343145701-3691-16-git-send-email-kys@microsoft.com>
References: <1343145672-3641-1-git-send-email-kys@microsoft.com>
 <1343145701-3691-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org, virtualization@lists.osdl.org,
	olaf@aepfle.de, apw@canonical.com, netdev@vger.kernel.org,
	ben@decadent.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343145701-3691-1-git-send-email-kys@microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of unused variables. I would like to thank Ben Hutchings
for pointing out the issue (ben@decadent.org.uk).

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 tools/hv/hv_kvp_daemon.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/hv/hv_kvp_daemon.c b/tools/hv/hv_kvp_daemon.c
index 3bce574..e72d6db 100644
--- a/tools/hv/hv_kvp_daemon.c
+++ b/tools/hv/hv_kvp_daemon.c
@@ -206,7 +206,7 @@ static void kvp_update_mem_state(int pool)
 }
 static int kvp_file_init(void)
 {
-	int ret, fd;
+	int  fd;
 	FILE *filep;
 	size_t records_read;
 	__u8 *fname;
@@ -322,7 +322,6 @@ static int kvp_key_add_or_modify(int pool, __u8 *key, int key_size, __u8 *value,
 			int value_size)
 {
 	int i;
-	int j, k;
 	int num_records;
 	struct kvp_record *record;
 	int num_blocks;
-- 
1.7.4.1
