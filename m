From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: unix: make some variables constant
Date: Tue, 19 Oct 2010 13:24:02 +0800
Message-ID: <1287465842-2958-1-git-send-email-xiaosuo@gmail.com>
Cc: netdev@vger.kernel.org, Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:55252 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388Ab0JSFYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 01:24:20 -0400
Received: by gxk21 with SMTP id 21so513583gxk.19
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 22:24:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And since ctl_table.data is initialized later, we don't need to initialize
the data member of the template variable unix_table.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/unix/sysctl_net_unix.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)
diff --git a/net/unix/sysctl_net_unix.c b/net/unix/sysctl_net_unix.c
index 397cffe..1114ccc 100644
--- a/net/unix/sysctl_net_unix.c
+++ b/net/unix/sysctl_net_unix.c
@@ -15,10 +15,9 @@
 
 #include <net/af_unix.h>
 
-static ctl_table unix_table[] = {
+const static ctl_table unix_table[] = {
 	{
 		.procname	= "max_dgram_qlen",
-		.data		= &init_net.unx.sysctl_max_dgram_qlen,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
@@ -26,7 +25,7 @@ static ctl_table unix_table[] = {
 	{ }
 };
 
-static struct ctl_path unix_path[] = {
+const static struct ctl_path unix_path[] = {
 	{ .procname = "net", },
 	{ .procname = "unix", },
 	{ },
