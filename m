From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] net:ethernet:intel:Remove outdated fix me
	comment in the function, gb_acquire_swfw_sync_i210
Date: Sun,  8 Feb 2015 00:21:50 -0500
Message-ID: <1423372910-29183-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	bruce.w.allan@intel.com, jesse.brandeburg@intel.com,
	linux-kernel@vger.kernel.org, john.ronciak@intel.com,
	netdev@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Removes the outdated fix me comment in the function,gb_acquire_swfw_sync_i210
for setting the variables, i and timeout to the intended correct values for
the function,gb_acquire_swfw_sync_i210 to function correctly. This comment is
no longer due to these values having been no changed in the last few years and
no known issues have been found for these variables being set to their current
values. Due to this the comment can now be removed as the values set for these
variables are known to be correct after years of no known issues or bugs related
to their current values.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 drivers/net/ethernet/intel/igb/e1000_i210.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/e1000_i210.c b/drivers/net/ethernet/intel/igb/e1000_i210.c
index 65d9316..0c169e5 100644
--- a/drivers/net/ethernet/intel/igb/e1000_i210.c
+++ b/drivers/net/ethernet/intel/igb/e1000_i210.c
@@ -140,7 +140,7 @@ s32 igb_acquire_swfw_sync_i210(struct e1000_hw *hw, u16 mask)
 	u32 swmask = mask;
 	u32 fwmask = mask << 16;
 	s32 ret_val = 0;
-	s32 i = 0, timeout = 200; /* FIXME: find real value to use here */
+	s32 i = 0, timeout = 200;
 
 	while (i < timeout) {
 		if (igb_get_hw_semaphore_i210(hw)) {
-- 
2.1.0


------------------------------------------------------------------------------
Dive into the World of Parallel Programming. The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
