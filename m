From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH] textsearch: doc - fix spelling in lib/textsearch.c.
Date: Mon, 24 Jan 2011 13:41:37 +0100
Message-ID: <20110124124137.10202.47152.stgit@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sander.contrib@gmail.com,
	Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:41292 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752344Ab1AXMlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jan 2011 07:41:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found the following spelling errors while reading the textsearch code:
  "facitilies"  -> "facilities"
  "continously" -> "continuously"
  "arbitary"    -> "arbitrary"
  "patern"      -> "pattern"
  "occurences"  -> "occurrences"

I'll try to push this patch through DaveM, given the only users
of textsearch is in the net/ tree (nf_conntrack_amanda.c, xt_string.c
and em_text.c)

Signed-off-by: Jesper Sander <sander.contrib@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 lib/textsearch.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/textsearch.c b/lib/textsearch.c
index d608331..e0cc014 100644
--- a/lib/textsearch.c
+++ b/lib/textsearch.c
@@ -13,7 +13,7 @@
  *
  * INTRODUCTION
  *
- *   The textsearch infrastructure provides text searching facitilies for
+ *   The textsearch infrastructure provides text searching facilities for
  *   both linear and non-linear data. Individual search algorithms are
  *   implemented in modules and chosen by the user.
  *
@@ -43,7 +43,7 @@
  *       to the algorithm to store persistent variables.
  *   (4) Core eventually resets the search offset and forwards the find()
  *       request to the algorithm.
- *   (5) Algorithm calls get_next_block() provided by the user continously
+ *   (5) Algorithm calls get_next_block() provided by the user continuously
  *       to fetch the data to be searched in block by block.
  *   (6) Algorithm invokes finish() after the last call to get_next_block
  *       to clean up any leftovers from get_next_block. (Optional)
@@ -58,15 +58,15 @@
  *   the pattern to look for and flags. As a flag, you can set TS_IGNORECASE
  *   to perform case insensitive matching. But it might slow down
  *   performance of algorithm, so you should use it at own your risk.
- *   The returned configuration may then be used for an arbitary
+ *   The returned configuration may then be used for an arbitrary
  *   amount of times and even in parallel as long as a separate struct
  *   ts_state variable is provided to every instance.
  *
  *   The actual search is performed by either calling textsearch_find_-
  *   continuous() for linear data or by providing an own get_next_block()
  *   implementation and calling textsearch_find(). Both functions return
- *   the position of the first occurrence of the patern or UINT_MAX if
- *   no match was found. Subsequent occurences can be found by calling
+ *   the position of the first occurrence of the pattern or UINT_MAX if
+ *   no match was found. Subsequent occurrences can be found by calling
  *   textsearch_next() regardless of the linearity of the data.
  *
  *   Once you're done using a configuration it must be given back via

