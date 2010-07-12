From: Joe Perches <joe@perches.com>
Subject: [PATCH 31/36] net/core: Remove unnecessary casts of private_data
Date: Mon, 12 Jul 2010 13:50:23 -0700
Message-ID: <217e404708d336ed1ad3254c5ea6626ee94b6a3d.1278967121.git.joe@perches.com>
References: <cover.1278967120.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1799 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab0GLUvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jul 2010 16:51:07 -0400
In-Reply-To: <cover.1278967120.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/core/pktgen.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 1ee2ebd..24a19de 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -846,7 +846,7 @@ static ssize_t pktgen_if_write(struct file *file,
 			       const char __user * user_buffer, size_t count,
 			       loff_t * offset)
 {
-	struct seq_file *seq = (struct seq_file *)file->private_data;
+	struct seq_file *seq = file->private_data;
 	struct pktgen_dev *pkt_dev = seq->private;
 	int i = 0, max, len;
 	char name[16], valstr[32];
@@ -1776,7 +1776,7 @@ static ssize_t pktgen_thread_write(struct file *file,
 				   const char __user * user_buffer,
 				   size_t count, loff_t * offset)
 {
-	struct seq_file *seq = (struct seq_file *)file->private_data;
+	struct seq_file *seq = file->private_data;
 	struct pktgen_thread *t = seq->private;
 	int i = 0, max, len, ret;
 	char name[40];
-- 
1.7.1.337.g6068.dirty

