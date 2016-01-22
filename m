From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH 1/3] xen-netback: fix license ident used in MODULE_LICENSE
Date: Fri, 22 Jan 2016 12:34:15 +0000
Message-ID: <1453466057-7176-2-git-send-email-wei.liu2@citrix.com>
References: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	"Wei Liu" <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	"open list:XEN NETWORK BACKEND DRIVER" <netdev@vger.kernel.org>,
	open list <linux-kernel@vger.kernel.org>
To: Xen-devel <xen-devel@lists.xenproject.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453466057-7176-1-git-send-email-wei.liu2@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The comment at the beginning of the file is the canonical source of
licenses for this module. Currently it contains GPL and MIT license. Fix
the code to reflect the reality.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 61b97c3..2427242 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -2192,5 +2192,5 @@ static void __exit netback_fini(void)
 }
 module_exit(netback_fini);
 
-MODULE_LICENSE("Dual BSD/GPL");
+MODULE_LICENSE("Dual MIT/GPL");
 MODULE_ALIAS("xen-backend:vif");
-- 
2.1.4
