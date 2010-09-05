From: Joe Perches <joe@perches.com>
Subject: [PATCH 11/13] net/ipv4: Remove unnecessary casts of private_data
Date: Sat,  4 Sep 2010 18:52:52 -0700
Message-ID: <dd5d79c3aa9f2cffbca1a8d4a9163b0d6a9492a9.1283650107.git.joe@perches.com>
References: <cover.1283650107.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1384 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754717Ab0IEBxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Sep 2010 21:53:11 -0400
In-Reply-To: <cover.1283650107.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/raw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1f85ef2..ea9aa9b 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -985,7 +985,7 @@ int raw_seq_open(struct inode *ino, struct file *file,
 	if (err < 0)
 		return err;
 
-	i = raw_seq_private((struct seq_file *)file->private_data);
+	i = raw_seq_private(file->private_data);
 	i->h = h;
 	return 0;
 }
-- 
1.7.2.19.g9a302

