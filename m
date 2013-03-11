From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qlcnic: remove duplicated include from qlcnic_sysfs.c
Date: Mon, 11 Mar 2013 22:29:50 +0800
Message-ID: <CAPgLHd8pPtK+uNtBEA1LBsS64qYe8M6R+OGnVcfq8BhKdds9BA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f41.google.com ([209.85.214.41]:62663 "EHLO
	mail-bk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872Ab3CKO3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 10:29:51 -0400
Received: by mail-bk0-f41.google.com with SMTP id q16so1744365bkw.0
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 07:29:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 987fb6f..4e464dc 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -21,8 +21,6 @@
 #include <linux/aer.h>
 #include <linux/log2.h>
 
-#include <linux/sysfs.h>
-
 #define QLC_STATUS_UNSUPPORTED_CMD	-2
 
 int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
