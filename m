From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 4/8] e1000e: lower ring minimum size to 64
Date: Wed, 23 Apr 2008 11:09:19 -0700
Message-ID: <20080423180919.24972.67080.stgit@localhost.localdomain>
References: <20080423180900.24972.84015.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080423180900.24972.84015.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

The lower limit of 80 descriptors in the ring is only valid for
one older 8254x chipset. All e1000e devices can use as low as
64 descriptors.

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000e/e1000.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index f6835c3..38bfd0d 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -64,11 +64,11 @@ struct e1000_info;
 /* Tx/Rx descriptor defines */
 #define E1000_DEFAULT_TXD		256
 #define E1000_MAX_TXD			4096
-#define E1000_MIN_TXD			80
+#define E1000_MIN_TXD			64
 
 #define E1000_DEFAULT_RXD		256
 #define E1000_MAX_RXD			4096
-#define E1000_MIN_RXD			80
+#define E1000_MIN_RXD			64
 
 #define E1000_MIN_ITR_USECS		10 /* 100000 irq/sec */
 #define E1000_MAX_ITR_USECS		10000 /* 100    irq/sec */


-------------------------------------------------------------------------
This SF.net email is sponsored by the 2008 JavaOne(SM) Conference 
Don't miss this year's exciting event. There's still time to save $100. 
Use priority code J8TL2D2. 
http://ad.doubleclick.net/clk;198757673;13503038;p?http://java.sun.com/javaone
