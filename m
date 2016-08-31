From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 1/8] net: make genetlink ctrl ops const
Date: Wed, 31 Aug 2016 15:22:00 -0700
Message-ID: <20160831152200.72ca2ac1@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33928 "EHLO
        mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751749AbcIAGZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:17 -0400
Received: by mail-pa0-f54.google.com with SMTP id fi15so26472638pac.1
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/netlink/genetlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
index a09132a..23cc126 100644
--- a/net/netlink/genetlink.c
+++ b/net/netlink/genetlink.c
@@ -977,7 +977,7 @@ static int genl_ctrl_event(int event, struct genl_family *family,
 	return 0;
 }
 
-static struct genl_ops genl_ctrl_ops[] = {
+static const struct genl_ops genl_ctrl_ops[] = {
 	{
 		.cmd		= CTRL_CMD_GETFAMILY,
 		.doit		= ctrl_getfamily,
@@ -986,7 +986,7 @@ static struct genl_ops genl_ctrl_ops[] = {
 	},
 };
 
-static struct genl_multicast_group genl_ctrl_groups[] = {
+static const struct genl_multicast_group genl_ctrl_groups[] = {
 	{ .name = "notify", },
 };
 
-- 
2.9.3
