From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 3/8] appletalk: fix warning: format not a string literal and
	no ...
Date: Wed, 25 Feb 2009 21:31:59 +0100
Message-ID: <20090225203145.6251.44085.stgit@vmbox.hanneseder.net>
References: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:42915 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758863AbZBYUjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 15:39:48 -0500
Received: by fxm24 with SMTP id 24so177450fxm.37
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2009 12:39:45 -0800 (PST)
In-Reply-To: <20090225203012.6251.32002.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Use 'static const char[]' instead of 'static char[]', and
since the data is const now it can be placed in __initconst.

Fix this warning:
  net/appletalk/ddp.c: In function 'atalk_init':
  net/appletalk/ddp.c:1894: warning: format not a string literal and no format arguments

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 net/appletalk/ddp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
index 510a678..cf05c43 100644
--- a/net/appletalk/ddp.c
+++ b/net/appletalk/ddp.c
@@ -1877,7 +1877,7 @@ EXPORT_SYMBOL(aarp_send_ddp);
 EXPORT_SYMBOL(atrtr_get_dev);
 EXPORT_SYMBOL(atalk_find_dev_addr);
 
-static char atalk_err_snap[] __initdata =
+static const char atalk_err_snap[] __initconst =
 	KERN_CRIT "Unable to register DDP with SNAP.\n";
 
 /* Called by proto.c on kernel start up */

