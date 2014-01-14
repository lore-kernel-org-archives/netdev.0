From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2.1 3/3] bonding: update bonding.txt for primary
 description
Date: Tue, 14 Jan 2014 18:54:17 +0800
Message-ID: <52D51759.20503@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:24048 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbaANKyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 05:54:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 Documentation/networking/bonding.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index a4d925e..5cdb229 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -657,7 +657,8 @@ primary
 	one slave is preferred over another, e.g., when one slave has
 	higher throughput than another.
 
-	The primary option is only valid for active-backup mode.
+	The primary option is only valid for active-backup(1),
+	balance-tlb (5) and balance-alb (6) mode.
 
 primary_reselect
 
-- 
1.8.0
