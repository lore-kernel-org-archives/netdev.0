From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 16/30] i40e: remove unnecessary break after
	return
Date: Sun, 20 Jul 2014 16:25:17 +0200
Message-ID: <1405866332-24652-7-git-send-email-fabf@skynet.be>
References: <1405866332-24652-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Fabian Frederick <fabf@skynet.be>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	joe@perches.com, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1405866332-24652-1-git-send-email-fabf@skynet.be>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c      | 1 -
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index 6e65f19..dd3a40d 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -554,7 +554,6 @@ i40e_status i40e_init_shared_code(struct i40e_hw *hw)
 		break;
 	default:
 		return I40E_ERR_DEVICE_NOT_SUPPORTED;
-		break;
 	}
 
 	hw->phy.get_link_info = true;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index f5b9d20..33ed628 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1785,7 +1785,6 @@ static int i40e_vc_validate_vf_msg(struct i40e_vf *vf, u32 v_opcode,
 	case I40E_VIRTCHNL_OP_UNKNOWN:
 	default:
 		return -EPERM;
-		break;
 	}
 	/* few more checks */
 	if ((valid_len != msglen) || (err_msg_format)) {
-- 
1.9.1


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
