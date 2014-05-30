From: David Ahern <dsahern@gmail.com>
Subject: [PATCH] fib_trie: use seq_file_net rather than seq->private
Date: Fri, 30 May 2014 13:34:39 -0600
Message-ID: <1401478479-77986-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:54734 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752203AbaE3TfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 15:35:00 -0400
Received: by mail-pd0-f179.google.com with SMTP id fp1so1275346pdb.10
        for <netdev@vger.kernel.org>; Fri, 30 May 2014 12:35:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make fib_triestat_seq_show consistent with other /proc/net files and
use seq_file_net.

Signed-off-by: David Ahern <dsahern@gmail.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/fib_trie.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 5afeb5aa4c7c..243c7f4e451e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -2166,7 +2166,7 @@ static void fib_table_print(struct seq_file *seq, struct fib_table *tb)
 
 static int fib_triestat_seq_show(struct seq_file *seq, void *v)
 {
-	struct net *net = (struct net *)seq->private;
+	struct net *net = seq_file_net(seq);
 	unsigned int h;
 
 	seq_printf(seq,
-- 
1.8.5.2 (Apple Git-48)
