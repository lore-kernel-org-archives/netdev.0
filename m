From: Alexey Dobriyan <adobriyan@openvz.org>
Subject: [PATCH] xt_hashlimit.c: fix typo
Date: Tue, 19 Dec 2006 18:57:33 +0300
Message-ID: <20061219155733.GA11147@localhost.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:7753 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753030AbWLSQc7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Dec 2006 11:32:59 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@openvz.org>
---

 net/netfilter/xt_hashlimit.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -745,7 +745,7 @@ static int __init xt_hashlimit_init(void
 	}
 	hashlimit_procdir6 = proc_mkdir("ip6t_hashlimit", proc_net);
 	if (!hashlimit_procdir6) {
-		printk(KERN_ERR "xt_hashlimit: tnable to create proc dir "
+		printk(KERN_ERR "xt_hashlimit: unable to create proc dir "
 				"entry\n");
 		goto err4;
 	}

