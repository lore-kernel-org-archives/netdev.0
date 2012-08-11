From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 13/15] ipv6: declaring rawv6 protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:16 +0900
Message-ID: <1344715638-22997-13-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring rawv6 protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv6/raw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ef0579d..62ac59f 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1226,6 +1226,7 @@ struct proto rawv6_prot = {
 	.compat_getsockopt = compat_rawv6_getsockopt,
 	.compat_ioctl	   = compat_rawv6_ioctl,
 #endif
+	.has_own_proc_entry= 1,
 };
 
 #ifdef CONFIG_PROC_FS
-- 
1.7.11.2
