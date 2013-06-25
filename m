From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 4/6] net: sctp: minor: sctp_seq_dump_local_addrs add missing newline
Date: Tue, 25 Jun 2013 17:13:39 +0200
Message-ID: <1372173221-15244-5-git-send-email-dborkman@redhat.com>
References: <1372173221-15244-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49561 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751846Ab3FYPNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 11:13:50 -0400
In-Reply-To: <1372173221-15244-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A trailing newline has been forgotten to add into the WARN().

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/sctp/proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 0c83162..62526c4 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -138,7 +138,7 @@ static void sctp_seq_dump_local_addrs(struct seq_file *seq, struct sctp_ep_commo
 
 		peer = asoc->peer.primary_path;
 		if (unlikely(peer == NULL)) {
-			WARN(1, "Association %p with NULL primary path!", asoc);
+			WARN(1, "Association %p with NULL primary path!\n", asoc);
 			return;
 		}
 
-- 
1.7.11.7
