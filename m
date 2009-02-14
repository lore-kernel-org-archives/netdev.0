From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 08/43] drivers/net/ppp*.c: fix sparse warnings: fix signedness
Date: Sat, 14 Feb 2009 22:13:52 +0100
Message-ID: <20090214211346.23489.96321.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f20.google.com ([209.85.220.20]:34276 "EHLO
	mail-fx0-f20.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374AbZBNVN5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:13:57 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix this sparse warnings:
  drivers/net/ppp_generic.c:919:43: warning: incorrect type in argument 1 (different signedness)
  drivers/net/pppoe.c:1195:43: warning: incorrect type in argument 1 (different signedness)
  drivers/net/pppol2tp.c:2666:43: warning: incorrect type in argument 1 (different signedness)

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/ppp_generic.c |    2 +-
 drivers/net/pppoe.c       |    2 +-
 drivers/net/pppol2tp.c    |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index fddc849..81e7fcc 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -183,7 +183,7 @@ static atomic_t ppp_unit_count = ATOMIC_INIT(0);
 static atomic_t channel_count = ATOMIC_INIT(0);
 
 /* per-net private data for this module */
-static unsigned int ppp_net_id;
+static int ppp_net_id;
 struct ppp_net {
 	/* units to ppp mapping */
 	struct idr units_idr;
diff --git a/drivers/net/pppoe.c b/drivers/net/pppoe.c
index af6321d..e2968f0 100644
--- a/drivers/net/pppoe.c
+++ b/drivers/net/pppoe.c
@@ -97,7 +97,7 @@ static const struct proto_ops pppoe_ops;
 static struct ppp_channel_ops pppoe_chan_ops;
 
 /* per-net private data for this module */
-static unsigned int pppoe_net_id;
+static int pppoe_net_id;
 struct pppoe_net {
 	/*
 	 * we could use _single_ hash table for all
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index 1ba0f68..5b07dd8 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -232,7 +232,7 @@ static struct ppp_channel_ops pppol2tp_chan_ops = { pppol2tp_xmit , NULL };
 static struct proto_ops pppol2tp_ops;
 
 /* per-net private data for this module */
-static unsigned int pppol2tp_net_id;
+static int pppol2tp_net_id;
 struct pppol2tp_net {
 	struct list_head pppol2tp_tunnel_list;
 	rwlock_t pppol2tp_tunnel_list_lock;

