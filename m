From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 5/8] qlcnic: Fix minidump in NPAR mode
Date: Wed, 30 Jan 2013 17:47:16 -0500
Message-ID: <1359586039-19051-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, sony.chacko@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:54066 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S932082Ab3A3XIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2013 18:08:24 -0500
In-Reply-To: <1359586039-19051-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c  |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index d394471..b3ef33a 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -98,6 +98,7 @@ static int qlcnic_83xx_init_mgmt_vnic(struct qlcnic_adapter *adapter)
 {
 	int err = -EIO;
 
+	qlcnic_83xx_get_minidump_template(adapter);
 	if (!(adapter->flags & QLCNIC_ADAPTER_INITIALIZED)) {
 		if (qlcnic_init_pci_info(adapter))
 			return err;
@@ -130,6 +131,7 @@ static int qlcnic_83xx_init_privileged_vnic(struct qlcnic_adapter *adapter)
 {
 	int err = -EIO;
 
+	qlcnic_83xx_get_minidump_template(adapter);
 	if (qlcnic_83xx_get_port_info(adapter))
 		return err;
 
-- 
1.7.1
