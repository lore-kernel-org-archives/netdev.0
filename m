From: Jan Engelhardt <jengelh@medozas.de>
Subject: iproute2: fix calling up the xt action
Date: Sat, 31 Dec 2011 23:18:27 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1112312317590.24158@frira.zrqbmnf.qr>
References: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Networking Developer Mailing List <netdev@vger.kernel.org>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from seven.medozas.de ([188.40.89.202]:50005 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251Ab1LaWS2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 31 Dec 2011 17:18:28 -0500
In-Reply-To: <alpine.LNX.2.01.1112312317220.24158@frira.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: 2011-06-01 00:52:07+0200
Upsteam: has not been sent yet

Requesting the xt action never succeeded because it registered
using the wrong name.

---
 tc/m_xt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: iproute2-2.6.37/tc/m_xt.c
===================================================================
--- iproute2-2.6.37.orig/tc/m_xt.c
+++ iproute2-2.6.37/tc/m_xt.c
@@ -343,8 +343,8 @@ print_ipt(struct action_util *au,FILE *
 	return 0;
 }
 
-struct action_util ipt_action_util = {
-        .id = "ipt",
+struct action_util xt_action_util = {
+        .id = "xt",
         .parse_aopt = parse_ipt,
         .print_aopt = print_ipt,
 };
