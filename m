From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: [PATCH net] busy_poll: cleanup do-nothing placeholders
Date: Sun, 04 Aug 2013 12:55:48 +0300
Message-ID: <20130804095548.30006.8133.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When renaming ll_poll to busy poll, I introduced a typo
in the name of the do-nothing placeholder for sk_busy_loop
and called it sk_busy_poll.
This broke compile when busy poll was not configured.
Cong Wang submitted a patch to fixed that.
This patch removes the now redundant, misspelled placeholder.

Signed-off-by: Eliezer Tamir <eliezer.tamir@linux.intel.com>
---

 include/net/busy_poll.h |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/include/net/busy_poll.h b/include/net/busy_poll.h
index f18b919..8e2dfc1 100644
--- a/include/net/busy_poll.h
+++ b/include/net/busy_poll.h
@@ -162,11 +162,6 @@ static inline bool sk_can_busy_loop(struct sock *sk)
 	return false;
 }
 
-static inline bool sk_busy_poll(struct sock *sk, int nonblock)
-{
-	return false;
-}
-
 static inline void skb_mark_napi_id(struct sk_buff *skb,
 				    struct napi_struct *napi)
 {
