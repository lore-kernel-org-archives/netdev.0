From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: qlge: remove duplicated #include
Date: Sun, 12 Oct 2008 17:23:24 +0800
Message-ID: <20081012171458.F6D4.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-driver@qlogic.com, ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.184]:30881 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751437AbYJLJXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 05:23:32 -0400
Received: by ti-out-0910.google.com with SMTP id b6so620908tic.23
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 02:23:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated include <linux/init.h> in files below
  drivers/net/qlge/qlge_ethtool.c
  drivers/net/qlge/qlge_main.c

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/qlge/qlge_ethtool.c b/drivers/net/qlge/qlge_ethtool.c
index 6457f8c..b62fbd4 100644
--- a/drivers/net/qlge/qlge_ethtool.c
+++ b/drivers/net/qlge/qlge_ethtool.c
@@ -29,7 +29,6 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
 #include <linux/vmalloc.h>

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 3af822b..297877b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -36,7 +36,6 @@
 #include <linux/skbuff.h>
 #include <linux/rtnetlink.h>
 #include <linux/if_vlan.h>
-#include <linux/init.h>
 #include <linux/delay.h>
 #include <linux/mm.h>
 #include <linux/vmalloc.h>

