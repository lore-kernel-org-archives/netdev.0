From: Wei Liu <wei.liu2@citrix.com>
Subject: [PATCH v2 1/3] xen-netback: fix license ident used in MODULE_LICENSE
Date: Fri, 22 Jan 2016 14:04:15 +0000
Message-ID: <1453471457-10908-2-git-send-email-wei.liu2@citrix.com>
References: <1453471457-10908-1-git-send-email-wei.liu2@citrix.com>
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
In-Reply-To: <1453471457-10908-1-git-send-email-wei.liu2@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The comment at the beginning of the file is the canonical source of
licenses for this module. The license used to distribute outside of
Linux kernel is not BSD license but X11 license. Instead of trying to
determine whether X11 license can be mapped into Linux's "MIT" license
ident, simply make the code to use "GPL" only.

Signed-off-by: Wei Liu <wei.liu2@citrix.com>
---
 drivers/net/xen-netback/netback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
index 61b97c3..e9601d1 100644
--- a/drivers/net/xen-netback/netback.c
+++ b/drivers/net/xen-netback/netback.c
@@ -2192,5 +2192,5 @@ static void __exit netback_fini(void)
 }
 module_exit(netback_fini);
 
-MODULE_LICENSE("Dual BSD/GPL");
+MODULE_LICENSE("GPL");
 MODULE_ALIAS("xen-backend:vif");
-- 
2.1.4
