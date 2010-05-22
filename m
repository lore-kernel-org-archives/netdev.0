From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: [PATCH 12/12] caif: remove duplicated #include
Date: Sun, 23 May 2010 01:13:29 +0800
Message-ID: <1274548409-3580-1-git-send-email-weiyi.huang@gmail.com>
Cc: netdev@vger.kernel.org, Huang Weiyi <weiyi.huang@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:54917 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677Ab0EVRNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 13:13:33 -0400
Received: by pxi18 with SMTP id 18so883358pxi.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 10:13:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove duplicated #include('s) in
  net/caif/caif_socket.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
---
 net/caif/caif_socket.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index c3a70c5..a9681c3 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -15,7 +15,6 @@
 #include <linux/poll.h>
 #include <linux/tcp.h>
 #include <linux/uaccess.h>
-#include <linux/mutex.h>
 #include <linux/debugfs.h>
 #include <linux/caif/caif_socket.h>
 #include <asm/atomic.h>
-- 
1.6.1.3

