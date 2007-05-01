From: Loic Prylli <loic@myri.com>
Subject: [PATCH] make myri10ge use default MTU of 1500 bytes
Date: Tue, 01 May 2007 15:43:08 -0700
Message-ID: <4637C27C.5060405@myri.com>
References: <4632894D.40705@hp.com>	<20070427.163934.106263903.davem@davemloft.net>	<46328BB0.9030501@hp.com> <20070427.165232.74560572.davem@davemloft.net> <46362475.3080605@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hp.com>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1877 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753568AbXEAWnN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2007 18:43:13 -0400
In-Reply-To: <46362475.3080605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change default MTU from jumbo (9000) to standard (1500) for myri10ge


Signed-off-by: Loic Prylli <loic@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 16e3c43..0e9cc17 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -252,7 +252,7 @@ module_param(myri10ge_force_firmware, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_force_firmware,
                 "Force firmware to assume aligned completions\n");
 
-static int myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
+static int myri10ge_initial_mtu  = 1500;
 module_param(myri10ge_initial_mtu, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_initial_mtu, "Initial MTU\n");
 
-- 
1.5.0.1



