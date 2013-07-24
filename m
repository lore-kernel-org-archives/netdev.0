From: Wang Sheng-Hui <shhuiw@gmail.com>
Subject: [PATCH] bonding: use pre-defined macro in bond_mode_name instead
 of magic number 0
Date: Wed, 24 Jul 2013 14:53:26 +0800
Message-ID: <51EF79E6.9060309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:58563 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752047Ab3GXGxj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 02:53:39 -0400
Received: by mail-ob0-f173.google.com with SMTP id er7so3682506obc.32
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 23:53:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have BOND_MODE_ROUNDROBIN pre-defined as 0, and it's the lowest mode number.
Use it to check the arg lower bound instead of magic number 0 in bond_mode_name.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
  drivers/net/bonding/bond_main.c |    2 +-
  1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07f257d4..5890def 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -273,7 +273,7 @@ const char *bond_mode_name(int mode)
  		[BOND_MODE_ALB] = "adaptive load balancing",
  	};

-	if (mode < 0 || mode > BOND_MODE_ALB)
+	if (mode < BOND_MODE_ROUNDROBIN || mode > BOND_MODE_ALB)
  		return "unknown";

  	return names[mode];
-- 
1.7.10.4
