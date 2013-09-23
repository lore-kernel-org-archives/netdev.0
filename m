From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH] i40e: remove unused including <linux/version.h>
Date: Mon, 23 Sep 2013 11:39:11 +0800
Message-ID: <CAPgLHd9B7h-w7sXPep5baH9XV=Yb1zNAU539hLm+Zx+6PRnejg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, gregory.v.rose@intel.com,
	peter.p.waskiewicz.jr@intel.com, alexander.h.duyck@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	shannon.nelson@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:59072 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023Ab3IWDjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Sep 2013 23:39:13 -0400
Received: by mail-bk0-f49.google.com with SMTP id r7so955029bkg.8
        for <netdev@vger.kernel.org>; Sun, 22 Sep 2013 20:39:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove including <linux/version.h> that don't need it.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/intel/i40e/i40e.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index b5252eb..3f232ab 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -46,7 +46,6 @@
 #include <linux/sctp.h>
 #include <linux/pkt_sched.h>
 #include <linux/ipv6.h>
-#include <linux/version.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <linux/ethtool.h>
