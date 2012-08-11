From: Masatake YAMATO <yamato@redhat.com>
Subject: [PATCH v2 08/15] unix: declaring unix protocols has its own proc entry
Date: Sun, 12 Aug 2012 05:07:11 +0900
Message-ID: <1344715638-22997-8-git-send-email-yamato@redhat.com>
References: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Cc: linux-kernel@vger.kernel.org, Masatake YAMATO <yamato@redhat.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344715638-22997-1-git-send-email-yamato@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Declaring unix protocols has its own proc entry.

Signed-off-by: Masatake YAMATO <yamato@redhat.com>
---
 net/unix/af_unix.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index e4768c1..7f109e6 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -616,6 +616,7 @@ static struct proto unix_proto = {
 	.name			= "UNIX",
 	.owner			= THIS_MODULE,
 	.obj_size		= sizeof(struct unix_sock),
+	.has_own_proc_entry= 1,
 };
 
 /*
-- 
1.7.11.2
