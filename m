From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: hip04: add missing MODULE_LICENSE
Date: Fri, 30 Jan 2015 22:57:01 +0100
Message-ID: <4018099.9I7f6kd5jC@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	Zhangfei Gao <zhangfei.gao@linaro.org>,
	Ding Tianhong <dingtianhong@huawei.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:51704 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876AbbA3V5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2015 16:57:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hip04 ethernet driver causes a new compile-time warning
when built as a loadable module:

WARNING: modpost: missing MODULE_LICENSE() in drivers/net/ethernet/hisilicon/hip04_eth.o
see include/linux/module.h for more information

This adds the license as "GPL", which matches the header of the file.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
index c02b81bcfffb..b72d238695d7 100644
--- a/drivers/net/ethernet/hisilicon/hip04_eth.c
+++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
@@ -968,3 +968,4 @@ static struct platform_driver hip04_mac_driver = {
 module_platform_driver(hip04_mac_driver);
 
 MODULE_DESCRIPTION("HISILICON P04 Ethernet driver");
+MODULE_LICENSE("GPL");
