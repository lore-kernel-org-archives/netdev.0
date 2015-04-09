From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/5 v2] nfc: Fix portid type in urelease_work
Date: Thu,  9 Apr 2015 23:57:14 +0200
Message-ID: <1428616637-21690-2-git-send-email-richard@nod.at>
References: <1428616637-21690-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1428616637-21690-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

portid is an unsigned integer. Fix urelease_work to
match all other portid user in the kernel.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/nfc/netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 14a2d11..3763036 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1584,7 +1584,7 @@ static const struct genl_ops nfc_genl_ops[] = {
 
 struct urelease_work {
 	struct	work_struct w;
-	int	portid;
+	u32	portid;
 };
 
 static void nfc_urelease_event_work(struct work_struct *work)
-- 
1.8.4.5
