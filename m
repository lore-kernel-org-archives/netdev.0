From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 3/3] bonding: update Documentation/networking/bonding.txt
 for option lp_interval
Date: Fri, 20 Dec 2013 13:11:02 +0800
Message-ID: <52B3D166.8010706@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:30304 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908Ab3LTFLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 00:11:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 Documentation/networking/bonding.txt | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 2cdb8b6..a4d925e 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -853,6 +853,14 @@ resend_igmp
 
 	This option was added for bonding version 3.7.0.
 
+lp_interval
+
+	Specifies the number of seconds between instances where the bonding
+	driver sends learning packets to each slaves peer switch.
+
+	The valid range is 1 - 0x7fffffff; the default value is 1. This Option
+	has effect only in balance-tlb and balance-alb modes.
+
 3. Configuring Bonding Devices
 ==============================
 
-- 
1.8.0
