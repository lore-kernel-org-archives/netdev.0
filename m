From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next 2/2] e1000e: delete excessive space
	character in debug message
Date: Sat,  2 Aug 2014 20:37:11 -0600
Message-ID: <1407026820-26552-3-git-send-email-mysctp@gmail.com>
References: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Linux NICS <linux.nics@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	<aaron.f.brown@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
In-Reply-To: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
References: <1407026820-26552-1-git-send-email-mysctp@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

There is an excessive space character between the word and the
period in the debug message. So delete it.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/manage.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/manage.c b/drivers/net/ethernet/intel/e1000e/manage.c
index 58856032298d..38a0a83b1400 100644
--- a/drivers/net/ethernet/intel/e1000e/manage.c
+++ b/drivers/net/ethernet/intel/e1000e/manage.c
@@ -78,7 +78,7 @@ static s32 e1000_mng_enable_host_if(struct e1000_hw *hw)
 	}
 
 	if (i == E1000_MNG_DHCP_COMMAND_TIMEOUT) {
-		e_dbg("Previous command timeout failed .\n");
+		e_dbg("Previous command timeout failed.\n");
 		return -E1000_ERR_HOST_INTERFACE_COMMAND;
 	}
 

------------------------------------------------------------------------------
Want fast and easy access to all the code in your enterprise? Index and
search up to 200,000 lines of code with a free copy of Black Duck
Code Sight - the same software that powers the world's largest code
search on Ohloh, the Black Duck Open Hub! Try it now.
http://p.sf.net/sfu/bds
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
