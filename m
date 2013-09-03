From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qlcnic: remove a stray semicolon
Date: Tue, 3 Sep 2013 12:13:47 +0300
Message-ID: <20130903091347.GA4630@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Himanshu Madhani <himanshu.madhani@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Just remove a small semicolon.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 332aa71..4d7ad00 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1709,7 +1709,7 @@ qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
 		qlcnic_dev_request_reset(adapter, val->flag);
 		adapter->flags &= ~QLCNIC_FW_RESET_OWNER;
 		break;
-;
+
 	case QLCNIC_SET_QUIESCENT:
 	case QLCNIC_RESET_QUIESCENT:
 		state = QLC_SHARED_REG_RD32(adapter, QLCNIC_CRB_DEV_STATE);
