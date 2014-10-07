From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 net-next] af_unix: remove 0 assignment on static
Date: Tue,  7 Oct 2014 23:02:15 +0200
Message-ID: <1412715735-6757-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

static values are automatically initialized to 0

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: replace NULL by 0 in description

 net/unix/garbage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/garbage.c b/net/unix/garbage.c
index 9bc73f8..99f7012 100644
--- a/net/unix/garbage.c
+++ b/net/unix/garbage.c
@@ -258,7 +258,7 @@ static void inc_inflight_move_tail(struct unix_sock *u)
 		list_move_tail(&u->link, &gc_candidates);
 }
 
-static bool gc_in_progress = false;
+static bool gc_in_progress;
 #define UNIX_INFLIGHT_TRIGGER_GC 16000
 
 void wait_for_unix_gc(void)
-- 
1.9.3
