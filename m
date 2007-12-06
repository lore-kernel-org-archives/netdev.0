From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 14/20] net/ipv4/cipso_ipv4.c: use LIST_HEAD instead of LIST_HEAD_INIT
Date: Fri,  7 Dec 2007 00:04:36 +0800
Message-ID: <1196957076-5706-1-git-send-email-crquan@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753044AbXLFQFW@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

single list_head variable initialized with LIST_HEAD_INIT could almost
always can be replaced with LIST_HEAD declaration, this shrinks the code
and looks better.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 net/ipv4/cipso_ipv4.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/cipso_ipv4.c b/net/ipv4/cipso_ipv4.c
index f18e88b..d4dc4eb 100644
--- a/net/ipv4/cipso_ipv4.c
+++ b/net/ipv4/cipso_ipv4.c
@@ -63,7 +63,7 @@ struct cipso_v4_domhsh_entry {
  * probably be turned into a hash table or something similar so we
  * can do quick lookups. */
 static DEFINE_SPINLOCK(cipso_v4_doi_list_lock);
-static struct list_head cipso_v4_doi_list = LIST_HEAD_INIT(cipso_v4_doi_list);
+static LIST_HEAD(cipso_v4_doi_list);
 
 /* Label mapping cache */
 int cipso_v4_cache_enabled = 1;
-- 
1.5.3.4

