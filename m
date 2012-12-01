From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] qlcnic: remove duplicated include from qlcnic_sysfs.c
Date: Sat, 1 Dec 2012 01:01:25 -0500
Message-ID: <CAPgLHd9rUSTcdop1coRzR00SxwHtetQ5vHwAfLN_Jw1VjaK68g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, linux-driver@qlogic.com,
	netdev@vger.kernel.org
To: jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f46.google.com ([209.85.216.46]:61490 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751067Ab2LAGB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 01:01:26 -0500
Received: by mail-qa0-f46.google.com with SMTP id r4so165530qaq.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 22:01:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Remove duplicated include.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
index 10a702a..bdaa8ce 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_sysfs.c
@@ -13,8 +13,6 @@
 #include <linux/aer.h>
 #include <linux/log2.h>
 
-#include <linux/sysfs.h>
-
 int qlcnicvf_config_bridged_mode(struct qlcnic_adapter *adapter, u32 enable)
 {
 	return -EOPNOTSUPP;
