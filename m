From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] decnet: remove duplicated include from dn_table.c
Date: Thu, 4 Apr 2013 09:33:07 +0800
Message-ID: <CAPgLHd-7CZLD7qCbR04iWWFRgdvW=aru06MF1JnW58dKvg5NTw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn,
	linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org
To: davem@davemloft.net, tgraf@suug.ch, shemminger@vyatta.com,
	sasha.levin@oracle.com, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f47.google.com ([209.85.214.47]:56241 "EHLO
	mail-bk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761055Ab3DDBdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 21:33:08 -0400
Received: by mail-bk0-f47.google.com with SMTP id ik5so1166654bkc.6
        for <netdev@vger.kernel.org>; Wed, 03 Apr 2013 18:33:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/decnet/dn_table.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/decnet/dn_table.c b/net/decnet/dn_table.c
index b15c1d1..86e3807 100644
--- a/net/decnet/dn_table.c
+++ b/net/decnet/dn_table.c
@@ -19,7 +19,6 @@
 #include <linux/sockios.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <net/netlink.h>
 #include <linux/rtnetlink.h>
 #include <linux/proc_fs.h>
 #include <linux/netdevice.h>
