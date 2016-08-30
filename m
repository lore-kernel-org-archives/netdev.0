From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/8] afs: Need linux/random.h
Date: Tue, 30 Aug 2016 16:42:12 +0100
Message-ID: <147257173214.6391.7174435935301987881.stgit@warthog.procyon.org.uk>
References: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147257169706.6391.3116382288289485794.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We should #include linux/random.h to use get_random().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/afs/main.c b/fs/afs/main.c
index 35de0c04729f..0b187ef3b5b7 100644
--- a/fs/afs/main.c
+++ b/fs/afs/main.c
@@ -14,6 +14,7 @@
 #include <linux/init.h>
 #include <linux/completion.h>
 #include <linux/sched.h>
+#include <linux/random.h>
 #include "internal.h"
 
 MODULE_DESCRIPTION("AFS Client File System");
