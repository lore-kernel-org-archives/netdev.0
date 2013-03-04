From: Alexandru Gheorghiu <gheorghiuandru@gmail.com>
Subject: [PATCH] net: netfilter: nfnetlink: Fixed warning for nfnl_get_lock
Date: Mon,  4 Mar 2013 21:43:11 +0200
Message-ID: <1362426192-2921-1-git-send-email-gheorghiuandru@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandru Gheorghiu <gheorghiuandru@gmail.com>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removed unused function nfnl_get_lock which fixed the following warning=
:
net/netfilter/nfnetlink.c:65:22: warning: =E2=80=98nfnl_get_lock=E2=80=99=
 defined but not used [-Wunused-function]

Signed-off-by: Alexandru Gheorghiu <gheorghiuandru@gmail.com>
---
 net/netfilter/nfnetlink.c |    5 -----
 1 file changed, 5 deletions(-)

diff --git a/net/netfilter/nfnetlink.c b/net/netfilter/nfnetlink.c
index d578ec2..44aa0a7 100644
--- a/net/netfilter/nfnetlink.c
+++ b/net/netfilter/nfnetlink.c
@@ -62,11 +62,6 @@ void nfnl_unlock(__u8 subsys_id)
 }
 EXPORT_SYMBOL_GPL(nfnl_unlock);

-static struct mutex *nfnl_get_lock(__u8 subsys_id)
-{
-	return &table[subsys_id].mutex;
-}
-
 int nfnetlink_subsys_register(const struct nfnetlink_subsystem *n)
 {
 	nfnl_lock(n->subsys_id);
--
1.7.9.5
