From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Fw: [Bugme-new] [Bug 3706] New: Kernel build fails on sungem
 driver compile.
Date: Fri, 5 Nov 2004 16:09:58 -0800
Message-ID: <20041105160958.7e169484.davem@davemloft.net>
References: <20041105153040.564f1c2a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041105153040.564f1c2a.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I fixed this in my tree as follows:

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/11/05 15:57:06-08:00 davem@nuts.davemloft.net 
#   [SUNGEM]: Use CONFIG_PPC_PMAC throughout.
#   
#   Fixes some build failures ala bugme bugzilla #3706
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# drivers/net/sungem.c
#   2004/11/05 15:56:15-08:00 davem@nuts.davemloft.net +1 -1
#   [SUNGEM]: Use CONFIG_PPC_PMAC throughout.
# 
diff -Nru a/drivers/net/sungem.c b/drivers/net/sungem.c
--- a/drivers/net/sungem.c	2004-11-05 15:57:28 -08:00
+++ b/drivers/net/sungem.c	2004-11-05 15:57:28 -08:00
@@ -2681,7 +2681,7 @@
 	return rc;
 }
 
-#if (!defined(__sparc__) && !defined(CONFIG_PPC))
+#if (!defined(__sparc__) && !defined(CONFIG_PPC_PMAC))
 /* Fetch MAC address from vital product data of PCI ROM. */
 static void find_eth_addr_in_vpd(void __iomem *rom_base, int len, unsigned char *dev_addr)
 {
