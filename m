From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] sfc: remove duplicated include from efx.c
Date: Wed, 13 Mar 2013 21:02:20 +0800
Message-ID: <CAPgLHd-iidouP5+3R1vgVQ8s3Ad-=10m92aGvGwJ1epeF0ob9A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: linux-net-drivers@solarflare.com, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:48825 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755167Ab3CMNCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 09:02:21 -0400
Received: by mail-bk0-f42.google.com with SMTP id jk7so438447bkc.15
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 06:02:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/sfc/efx.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index f050248..78c3324 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -21,7 +21,6 @@
 #include <linux/ethtool.h>
 #include <linux/topology.h>
 #include <linux/gfp.h>
-#include <linux/pci.h>
 #include <linux/cpu_rmap.h>
 #include <linux/aer.h>
 #include "net_driver.h"
