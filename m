From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] ppp: section fixes re netns
Date: Tue, 10 Feb 2009 01:22:38 +0300
Message-ID: <20090209222238.GA9692@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:23158 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753207AbZBIWQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 17:16:32 -0500
Received: by fg-out-1718.google.com with SMTP id 16so1166679fgg.17
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 14:16:29 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PPP is modular code so no initdata on netns hooks.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/ppp_generic.c |    2 +-
 drivers/net/pppoe.c       |    2 +-
 drivers/net/pppol2tp.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -901,7 +901,7 @@ static __net_exit void ppp_exit_net(struct net *net)
 	kfree(pn);
 }
 
-static __net_initdata struct pernet_operations ppp_net_ops = {
+static struct pernet_operations ppp_net_ops = {
 	.init = ppp_init_net,
 	.exit = ppp_exit_net,
 };
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -1175,7 +1175,7 @@ static __net_exit void pppoe_exit_net(struct net *net)
 	kfree(pn);
 }
 
-static __net_initdata struct pernet_operations pppoe_net_ops = {
+static struct pernet_operations pppoe_net_ops = {
 	.init = pppoe_init_net,
 	.exit = pppoe_exit_net,
 };
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -2647,7 +2647,7 @@ static __net_exit void pppol2tp_exit_net(struct net *net)
 	kfree(pn);
 }
 
-static __net_initdata struct pernet_operations pppol2tp_net_ops = {
+static struct pernet_operations pppol2tp_net_ops = {
 	.init = pppol2tp_init_net,
 	.exit = pppol2tp_exit_net,
 };
