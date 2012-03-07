From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Subject: [PATCH 1/2] bridge: br_log_state() s/entering/entered/
Date: Wed, 07 Mar 2012 10:25:14 +0200
Message-ID: <20120307082514.6293.59158.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:60550 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750898Ab2CGIZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 03:25:18 -0500
Received: by lahj13 with SMTP id j13so6990395lah.19
        for <netdev@vger.kernel.org>; Wed, 07 Mar 2012 00:25:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When br_log_state() is reporting state it should say "entered"
istead of "entering" since state at this point is already
changed.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>
---

 net/bridge/br_stp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
index 6751ed4..8c836d9 100644
--- a/net/bridge/br_stp.c
+++ b/net/bridge/br_stp.c
@@ -31,7 +31,7 @@ static const char *const br_port_state_names[] = {
 
 void br_log_state(const struct net_bridge_port *p)
 {
-	br_info(p->br, "port %u(%s) entering %s state\n",
+	br_info(p->br, "port %u(%s) entered %s state\n",
 		(unsigned) p->port_no, p->dev->name,
 		br_port_state_names[p->state]);
 }
