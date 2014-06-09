From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qlcnic: remove duplicate QLC_83XX_GET_LSO_CAPABILITY define
Date: Mon, 9 Jun 2014 17:55:39 +0300
Message-ID: <20140609145539.GB9600@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Shahed Shaikh <shahed.shaikh@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The QLC_83XX_GET_LSO_CAPABILITY define is cut and pasted twice so we can
delete the second instance.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
index 97784d0..2bf101a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.h
@@ -418,7 +418,6 @@ enum qlcnic_83xx_states {
 #define QLC_83XX_GET_FUNC_MODE_FROM_NPAR_INFO(val)	(val & 0x80000000)
 #define QLC_83XX_GET_LRO_CAPABILITY(val)		(val & 0x20)
 #define QLC_83XX_GET_LSO_CAPABILITY(val)		(val & 0x40)
-#define QLC_83XX_GET_LSO_CAPABILITY(val)		(val & 0x40)
 #define QLC_83XX_GET_HW_LRO_CAPABILITY(val)		(val & 0x400)
 #define QLC_83XX_GET_VLAN_ALIGN_CAPABILITY(val)	(val & 0x4000)
 #define QLC_83XX_GET_FW_LRO_MSS_CAPABILITY(val)	(val & 0x20000)
