From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next 3/6] qlcnic: Print firmware minidump buffer and template header addresses
Date: Fri, 7 Aug 2015 07:17:04 -0400
Message-ID: <1438946227-11426-4-git-send-email-shahed.shaikh@qlogic.com>
References: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62943 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752979AbbHGMCz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 08:02:55 -0400
In-Reply-To: <1438946227-11426-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_minidump.c   |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
index aca47fd..cda9e60 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_minidump.c
@@ -1388,8 +1388,9 @@ int qlcnic_dump_fw(struct qlcnic_adapter *adapter)
 	fw_dump->clr = 1;
 	snprintf(mesg, sizeof(mesg), "FW_DUMP=%s", adapter->netdev->name);
 	netdev_info(adapter->netdev,
-		    "Dump data %d bytes captured, template header size %d bytes\n",
-		    fw_dump->size, fw_dump->tmpl_hdr_size);
+		    "Dump data %d bytes captured, dump data address = %p, template header size %d bytes, template address = %p\n",
+		    fw_dump->size, fw_dump->data, fw_dump->tmpl_hdr_size,
+		    fw_dump->tmpl_hdr);
 	/* Send a udev event to notify availability of FW dump */
 	kobject_uevent_env(&dev->kobj, KOBJ_CHANGE, msg);
 
-- 
1.5.6
