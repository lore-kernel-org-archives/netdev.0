From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc3 3/5] r8169: typo in debugging code
Date: Sat, 12 Feb 2005 00:42:36 +0100
Message-ID: <20050211234236.GB13644@electric-eye.fr.zoreil.com>
References: <20050211233918.GB8792@electric-eye.fr.zoreil.com> <20050211234106.GA13644@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, jdmason@us.ibm.com, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050211234106.GA13644@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Typo in debugging code.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-370 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-370	2005-02-05 21:04:22.000000000 +0100
+++ b/drivers/net/r8169.c	2005-02-12 00:25:04.364126556 +0100
@@ -79,7 +79,7 @@ VERSION 2.2LK	<2005/01/25>
 	        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
         	#expr,__FILE__,__FUNCTION__,__LINE__);		\
         }
-#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args) } while (0)
+#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args); } while (0)
 #else
 #define assert(expr) do {} while (0)
 #define dprintk(fmt, args...)	do {} while (0)

_
