From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for August 15 (bnx2) [resend/lost]
Date: Fri, 15 Aug 2008 15:17:15 -0700 (PDT)
Message-ID: <20080815.151715.111675039.davem@davemloft.net>
References: <20080815184032.3acd8032.sfr@canb.auug.org.au>
	<20080815084116.340ac526.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, mchan@broadcom.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20080815084116.340ac526.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 15 Aug 2008 08:41:16 -0700

> When VLAN is not enabled, bnx2 build fails with:
> 
> drivers/net/bnx2.c: In function 'bnx2_rx_int':
> drivers/net/bnx2.c:2959: error: dereferencing pointer to incomplete type
> drivers/net/bnx2.c:2960: error: dereferencing pointer to incomplete type
> make[2]: *** [drivers/net/bnx2.o] Error 1

Does this fix it for you?

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d454810..2486a65 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -35,8 +35,8 @@
 #include <linux/time.h>
 #include <linux/ethtool.h>
 #include <linux/mii.h>
-#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #include <linux/if_vlan.h>
+#if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
 #define BCM_VLAN 1
 #endif
 #include <net/ip.h>
