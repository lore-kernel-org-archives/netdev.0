From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 4/8] afs: Miscellaneous simple cleanups
Date: Tue, 30 Aug 2016 16:42:05 +0100
Message-ID: <147257172524.6391.15054443509484866693.stgit@warthog.procyon.org.uk>
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

Remove one #ifndef'd-out variable and a couple of excessive blank lines.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/afs/cmservice.c |    6 ------
 1 file changed, 6 deletions(-)

diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 85737e96ab8b..ca32d891bbc3 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -17,10 +17,6 @@
 #include "internal.h"
 #include "afs_cm.h"
 
-#if 0
-struct workqueue_struct *afs_cm_workqueue;
-#endif  /*  0  */
-
 static int afs_deliver_cb_init_call_back_state(struct afs_call *,
 					       struct sk_buff *, bool);
 static int afs_deliver_cb_init_call_back_state3(struct afs_call *,
@@ -282,7 +278,6 @@ static int afs_deliver_cb_callback(struct afs_call *call, struct sk_buff *skb,
 		break;
 	}
 
-
 	call->state = AFS_CALL_REPLYING;
 
 	/* we'll need the file server record as that tells us which set of
@@ -426,7 +421,6 @@ static void SRXAFSCB_ProbeUuid(struct work_struct *work)
 
 	_enter("");
 
-
 	if (memcmp(r, &afs_uuid, sizeof(afs_uuid)) == 0)
 		reply.match = htonl(0);
 	else
