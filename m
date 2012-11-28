From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 47/69]
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10137:48: sparse: cast
 truncates bits from constant value (ffff7fff becomes 7fff)
Date: Thu, 29 Nov 2012 03:15:02 +0800
Message-ID: <50b662b6.9aBw8MT3eX6Aany2%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eilon Greenstein <eilong@broadcom.com>
To: Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:11654 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932108Ab2K1TPc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2012 14:15:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   f4e0b4c5e1c3eac9b7376ce73fb63de436057db1
commit: 503976e99842665b3ebd6aec602525b9e8f38812 [47/69] bnx2x: Cosmetic changes


sparse warnings:

drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:13031:5: sparse: symbol 'bnx2x_pre_init_phy' was not declared. Should it be static?
+ drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:10137:48: sparse: cast truncates bits from constant value (ffff7fff becomes 7fff)

vim +10137 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c

c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10121  		else
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10122  			rc = bnx2x_8483x_disable_eee(phy, params, vars);
d231023e drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-20  10123  		if (rc) {
efc7ce03 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Masanari Iida 2012-11-02  10124  			DP(NETIF_MSG_LINK, "Failed to set EEE advertisement\n");
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10125  			return rc;
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10126  		}
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10127  	} else {
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10128  		vars->eee_status &= ~SHMEM_EEE_SUPPORTED_MASK;
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10129  	}
c8c60d88 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yuval Mintz   2012-06-06  10130  
0f6bb03d drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-11-27  10131  	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) ||
0f6bb03d drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-11-27  10132  	    (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834)) {
11b2ec6b drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-01-17  10133  		/* Bring PHY out of super isolate mode as the final step. */
503976e9 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-11-27  10134  		bnx2x_cl45_read_and_write(bp, phy,
503976e9 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-11-27  10135  					  MDIO_CTL_DEVAD,
503976e9 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-11-27  10136  					  MDIO_84833_TOP_CFG_XGPHY_STRAP1,
503976e9 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-11-27 @10137  					  (u16)~MDIO_84833_SUPER_ISOLATE);
11b2ec6b drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c Yaniv Rosner  2012-01-17  10138  	}
a22f0788 drivers/net/bnx2x/bnx2x_link.c                   Yaniv Rosner  2010-09-07  10139  	return rc;
de6eae1f drivers/net/bnx2x/bnx2x_link.c                   Yaniv Rosner  2010-09-07  10140  }
ea4e040a drivers/net/bnx2x_link.c                         Yaniv Rosner  2008-06-23  10141  
de6eae1f drivers/net/bnx2x/bnx2x_link.c                   Yaniv Rosner  2010-09-07  10142  static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
cd88ccee drivers/net/bnx2x/bnx2x_link.c                   Yaniv Rosner  2011-01-31  10143  				  struct link_params *params,
cd88ccee drivers/net/bnx2x/bnx2x_link.c                   Yaniv Rosner  2011-01-31  10144  				  struct link_vars *vars)
de6eae1f drivers/net/bnx2x/bnx2x_link.c                   Yaniv Rosner  2010-09-07  10145  {

---
0-DAY kernel build testing backend         Open Source Technology Center
Fengguang Wu, Yuanhan Liu                              Intel Corporation
