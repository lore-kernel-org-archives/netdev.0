From: Ameen Ali <ameenali023@gmail.com>
Subject: [PATCH] __aligned(size) is preferred over __attribute__((aligned(size)))
Date: Sun, 22 Feb 2015 23:40:36 +0200
Message-ID: <1424641236-7671-1-git-send-email-ameenali023@gmail.com>
Cc: linux-kernel@vger.kernel.org, Ameen Ali <ameenali023@gmail.com>,
	Ameen Ali <AmeenAli023@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ameen Ali <AmeenAli023@gmail.com>
---
 net/compat.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/compat.c b/net/compat.c
index 3236b41..49c6a8f 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -508,25 +508,25 @@ COMPAT_SYSCALL_DEFINE5(getsockopt, int, fd, int, level, int, optname,
 struct compat_group_req {
 	__u32				 gr_interface;
 	struct __kernel_sockaddr_storage gr_group
-		__attribute__ ((aligned(4)));
+		__aligned(4);
 } __packed;
 
 struct compat_group_source_req {
 	__u32				 gsr_interface;
 	struct __kernel_sockaddr_storage gsr_group
-		__attribute__ ((aligned(4)));
+		__aligned(4);
 	struct __kernel_sockaddr_storage gsr_source
-		__attribute__ ((aligned(4)));
+		__aligned(4);
 } __packed;
 
 struct compat_group_filter {
 	__u32				 gf_interface;
 	struct __kernel_sockaddr_storage gf_group
-		__attribute__ ((aligned(4)));
+		__aligned(4);
 	__u32				 gf_fmode;
 	__u32				 gf_numsrc;
 	struct __kernel_sockaddr_storage gf_slist[1]
-		__attribute__ ((aligned(4)));
+		__aligned(4);
 } __packed;
 
 #define __COMPAT_GF0_SIZE (sizeof(struct compat_group_filter) - \
-- 
2.1.0
