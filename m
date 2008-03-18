From: Joe Perches <joe@perches.com>
Subject: [PATCH 5/6] drivers/net/e1000 - Convert int16_t to s16
Date: Tue, 18 Mar 2008 09:13:48 -0700
Message-ID: <1c1d35f8165b53f5e1e050c88cf97922b0694229.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
	<41caf0b437b073665972eae10027d13c4ccb5097.1205779102.git.joe@perches.com>
	<d676af35dec3f20916505c18edea9ee1ae87a744.1205779102.git.joe@perches.com>
	<84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Auke Kok <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jeff Garzik <jgarzik@pobox.com>, Jeb Cramer <cramerj@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <84e6a8fed68d45f3271a23b7333bfd4627d646c1.1205779102.git.joe@perches.com>
In-Reply-To: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
References: <c9345fb555dc1a1aa8c3922c9957a73e43458469.1205779102.git.joe@perches.com>
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


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/e1000/e1000_hw.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 5d6c624..b5082fd 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -6148,7 +6148,7 @@ e1000_setup_led(struct e1000_hw *hw)
 int32_t
 e1000_blink_led_start(struct e1000_hw *hw)
 {
-    int16_t  i;
+    s16  i;
     u32 ledctl_blink = 0;
 
     DEBUGFUNC("e1000_id_led_blink_on");
-- 
1.5.4.rc2


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
