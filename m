From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH] [IPV4]: Formatting fix for /proc/net/fib_trie.
Date: Tue,  5 Feb 2008 12:58:56 +0300
Message-ID: <1202205536-9888-1-git-send-email-den@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	"Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:50053 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754259AbYBEJ6k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Feb 2008 04:58:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The line in the /proc/net/fib_trie for route with TOS specified
- has extra \n at the end
- does not have a space after route scope
like below.
           |-- 1.1.1.1
              /32 universe UNICASTtos =1

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 net/ipv4/fib_trie.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 35851c9..f5fba3f 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2431,8 +2431,7 @@ static int fib_trie_seq_show(struct seq_file *seq, void *v)
 					   rtn_type(buf2, sizeof(buf2),
 						    fa->fa_type));
 				if (fa->fa_tos)
-					seq_printf(seq, "tos =%d\n",
-						   fa->fa_tos);
+					seq_printf(seq, " tos=%d", fa->fa_tos);
 				seq_putc(seq, '\n');
 			}
 		}
-- 
1.5.3.rc5

