From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] ip_conntrack_helper_h323.c: EXPORT_SYMBOL'ed functions
	shouldn't be static
Date: Fri, 24 Mar 2006 01:08:01 +0100
Message-ID: <20060324000801.GM22727@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Jing Min Zhao <zhaojignmin@hotmail.com>
Content-Disposition: inline
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

EXPORT_SYMBOL'ed functions shouldn't be static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-mm1-full/net/ipv4/netfilter/ip_conntrack_helper_h323.c.old	2006-03-23 19:29:58.000000000 +0100
+++ linux-2.6.16-mm1-full/net/ipv4/netfilter/ip_conntrack_helper_h323.c	2006-03-23 19:30:39.000000000 +0100
@@ -639,8 +639,8 @@
 }
 
 /****************************************************************************/
-static int get_h225_addr(unsigned char *data, TransportAddress * addr,
-			 u_int32_t * ip, u_int16_t * port)
+int get_h225_addr(unsigned char *data, TransportAddress * addr,
+		  u_int32_t * ip, u_int16_t * port)
 {
 	unsigned char *p;
 
