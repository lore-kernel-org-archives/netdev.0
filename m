From: Eric Engestrom <eric.engestrom@imgtec.com>
Subject: [PATCH] net/ipv4: remove left over dead code
Date: Mon, 29 Feb 2016 16:38:06 +0000
Message-ID: <1456763886-993-1-git-send-email-eric.engestrom@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Engestrom <eric.engestrom@imgtec.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

8cc785f6f429c2a3fb81745dc142cbd72a462c4a ("net: ipv4: make the ping
/proc code AF-independent") removed the code using it, but renamed this
variable instead of removing it.

Signed-off-by: Eric Engestrom <eric.engestrom@imgtec.com>
---
 net/ipv4/ping.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index d3a2716..35179fc 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -1140,13 +1140,6 @@ static int ping_v4_seq_show(struct seq_file *seq, void *v)
 	return 0;
 }
 
-static const struct seq_operations ping_v4_seq_ops = {
-	.show		= ping_v4_seq_show,
-	.start		= ping_v4_seq_start,
-	.next		= ping_seq_next,
-	.stop		= ping_seq_stop,
-};
-
 static int ping_seq_open(struct inode *inode, struct file *file)
 {
 	struct ping_seq_afinfo *afinfo = PDE_DATA(inode);
-- 
2.7.1
