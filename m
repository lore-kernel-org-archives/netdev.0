From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] irda/qos.c: remove an unused function
Date: Fri, 29 Oct 2004 02:18:09 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041029001809.GJ29142@stusta.de>
References: <20041028222238.GP3207@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: irda-users@lists.sourceforge.net, davem@davemloft.net, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Dag Brattli <dagb@cs.uit.no>, Jean Tourrilhes <jt@hpl.hp.com>
Content-Disposition: inline
In-Reply-To: <20041028222238.GP3207@stusta.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ this time without the problems due to a digital signature... ]

The patch below removes an unused function from net/irda/qos.c


diffstat output:
 net/irda/qos.c |   11 -----------
 1 files changed, 11 deletions(-)


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.10-rc1-mm1-full/net/irda/qos.c.old	2004-10-28 23:51:59.000000000 +0200
+++ linux-2.6.10-rc1-mm1-full/net/irda/qos.c	2004-10-28 23:52:08.000000000 +0200
@@ -211,17 +211,6 @@
 	return index;
 }
 
-static inline __u32 byte_value(__u8 byte, __u32 *array) 
-{
-	int index;
-
-	ASSERT(array != NULL, return -1;);
-
-	index = msb_index(byte);
-
-	return index_value(index, array);
-}
-
 /*
  * Function value_lower_bits (value, array)
  *
