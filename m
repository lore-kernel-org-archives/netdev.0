From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 05/15] ipv4: declaring raw protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:08 +0900
Message-ID: <1344715638-22997-5-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring raw protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/ipv4/raw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index ff0f071..3980a4a 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -901,6 +901,7 @@ struct proto raw_prot = {
 	.compat_getsockopt = compat_raw_getsockopt,
 	.compat_ioctl	   = compat_raw_ioctl,
 #endif
+	.has_own_proc_entry= 1,
 };
 
 #ifdef CONFIG_PROC_FS
-- 
1.7.11.2
