From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] ip link: fix up bond/bridge slave id
Date: Tue,  6 Sep 2016 15:44:21 +0800
Message-ID: <1473147861-30544-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Jiri Pirko <jiri@resnulli.us>,
        Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34161 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753873AbcIFHog (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 03:44:36 -0400
Received: by mail-pf0-f195.google.com with SMTP id g202so10999210pfb.1
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 00:44:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 ip/iplink_bond_slave.c   | 2 +-
 ip/iplink_bridge_slave.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink_bond_slave.c b/ip/iplink_bond_slave.c
index 9c60dea..8a3104b 100644
--- a/ip/iplink_bond_slave.c
+++ b/ip/iplink_bond_slave.c
@@ -130,7 +130,7 @@ static void bond_slave_print_help(struct link_util *lu, int argc, char **argv,
 }
 
 struct link_util bond_slave_link_util = {
-	.id		= "bond",
+	.id		= "bond_slave",
 	.maxattr	= IFLA_BOND_SLAVE_MAX,
 	.print_opt	= bond_slave_print_opt,
 	.parse_opt	= bond_slave_parse_opt,
diff --git a/ip/iplink_bridge_slave.c b/ip/iplink_bridge_slave.c
index a44d4e4..58563e0 100644
--- a/ip/iplink_bridge_slave.c
+++ b/ip/iplink_bridge_slave.c
@@ -293,7 +293,7 @@ static void bridge_slave_print_help(struct link_util *lu, int argc, char **argv,
 }
 
 struct link_util bridge_slave_link_util = {
-	.id		= "bridge",
+	.id		= "bridge_slave",
 	.maxattr	= IFLA_BRPORT_MAX,
 	.print_opt	= bridge_slave_print_opt,
 	.parse_opt	= bridge_slave_parse_opt,
-- 
2.5.5
