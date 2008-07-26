From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: net/socket.c: removed duplicated include
Date: Sat, 26 Jul 2008 20:56:09 +0800
Message-ID: <20080726204541.AF61.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:64777 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbYGZM4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Jul 2008 08:56:11 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1951799tic.23
        for <netdev@vger.kernel.org>; Sat, 26 Jul 2008 05:56:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated include <linux/thread_info.h> in 
net/socket.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/net/socket.c b/net/socket.c
index 1310a82..76a87e7 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -69,7 +69,6 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 #include <linux/mutex.h>
-#include <linux/thread_info.h>
 #include <linux/wanrouter.h>
 #include <linux/if_bridge.h>
 #include <linux/if_frad.h>

