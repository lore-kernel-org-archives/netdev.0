From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/4] nfc: Fix portid type in urelease_work
Date: Fri, 13 Mar 2015 12:31:14 +0100
Message-ID: <1426246276-15839-3-git-send-email-richard@nod.at>
References: <1426246276-15839-1-git-send-email-richard@nod.at>
Cc: linux-wireless@vger.kernel.org, coreteam@netfilter.org,
	netfilter-devel@vger.kernel.org, linux-kernel@vger.kernel.org,
	sameo@linux.intel.com, aloisio.almeida@openbossa.org,
	lauro.venancio@openbossa.org, davem@davemloft.net,
	kadlec@blackhole.kfki.hu, kaber@trash.net, pablo@netfilter.org,
	Richard Weinberger <richard@nod.at>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426246276-15839-1-git-send-email-richard@nod.at>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

portid is an unsigned integer. Fix urelease_work to
match all other portid user in the kernel.

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 net/nfc/netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 14a2d11..1f12c4c 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -1583,8 +1583,8 @@ static const struct genl_ops nfc_genl_ops[] = {
 
 
 struct urelease_work {
-	struct	work_struct w;
-	int	portid;
+	struct		work_struct w;
+	unsigned int	portid;
 };
 
 static void nfc_urelease_event_work(struct work_struct *work)
-- 
1.8.4.5

