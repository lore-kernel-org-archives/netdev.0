From: Luis de Bethencourt <luisbg@osg.samsung.com>
Subject: [PATCH] net: add description for len argument of dev_get_phys_port_name
Date: Mon, 21 Mar 2016 16:31:14 +0000
Message-ID: <1458577874-28384-1-git-send-email-luisbg@osg.samsung.com>
Cc: davem@davemloft.net, edumazet@google.com, jiri@mellanox.com,
	ast@plumgrid.com, daniel@iogearbox.net, jarod@redhat.com,
	tom@herbertland.com, makita.toshiaki@lab.ntt.co.jp, ja@ssi.bg,
	netdev@vger.kernel.org,
	Luis de Bethencourt <luisbg@osg.samsung.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:55188 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbcCUQbi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Mar 2016 12:31:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the function dev_get_phys_port_name was added it missed a description
for it's len argument. Adding it.

Fixes: db24a9044ee1 ("net: add support for phys_port_name")
Signed-off-by: Luis de Bethencourt <luisbg@osg.samsung.com>
---
Hi,

Noticed this when running make htmldocs. It gives the following warning:
.//net/core/dev.c:6453: warning: No description found for parameter 'len'

Thanks,
Luis

 net/core/dev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 43c74ca..b9bcbe7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6445,6 +6445,7 @@ EXPORT_SYMBOL(dev_get_phys_port_id);
  *	dev_get_phys_port_name - Get device physical port name
  *	@dev: device
  *	@name: port name
+ *	@len: limit of bytes to copy to name
  *
  *	Get device physical port name
  */
-- 
2.6.4
