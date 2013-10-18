From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  11/14] i40e: reorder block declarations in debugfs
Date: Fri, 18 Oct 2013 06:23:15 -0700
Message-ID: <1382102598-11343-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: a@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:41785 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754529Ab3JRNXm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 09:23:42 -0400
In-Reply-To: <1382102598-11343-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

This is a cleanup of the arguments declared at the beginning
of each function.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 387bf94..246b177 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1147,9 +1147,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		i40e_veb_release(pf->veb[i]);
 
 	} else if (strncmp(cmd_buf, "add macaddr", 11) == 0) {
-		u8 ma[6];
-		int vlan = 0;
 		struct i40e_mac_filter *f;
+		int vlan = 0;
+		u8 ma[6];
 		int ret;
 
 		cnt = sscanf(&cmd_buf[11],
@@ -1185,8 +1185,8 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				 ma, vlan, vsi_seid, f, ret);
 
 	} else if (strncmp(cmd_buf, "del macaddr", 11) == 0) {
-		u8 ma[6];
 		int vlan = 0;
+		u8 ma[6];
 		int ret;
 
 		cnt = sscanf(&cmd_buf[11],
@@ -1222,9 +1222,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 				 ma, vlan, vsi_seid, ret);
 
 	} else if (strncmp(cmd_buf, "add pvid", 8) == 0) {
-		int v;
-		u16 vid;
 		i40e_status ret;
+		u16 vid;
+		int v;
 
 		cnt = sscanf(&cmd_buf[8], "%i %u", &vsi_seid, &v);
 		if (cnt != 2) {
@@ -1535,10 +1535,10 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 	} else if ((strncmp(cmd_buf, "add fd_filter", 13) == 0) ||
 		   (strncmp(cmd_buf, "rem fd_filter", 13) == 0)) {
 		struct i40e_fdir_data fd_data;
-		int ret;
 		u16 packet_len, i, j = 0;
 		char *asc_packet;
 		bool add = false;
+		int ret;
 
 		asc_packet = kzalloc(I40E_FDIR_MAX_RAW_PACKET_LOOKUP,
 				     GFP_KERNEL);
@@ -1626,9 +1626,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			}
 		} else if (strncmp(&cmd_buf[5],
 			   "get local", 9) == 0) {
+			u16 llen, rlen;
 			int ret, i;
 			u8 *buff;
-			u16 llen, rlen;
 			buff = kzalloc(I40E_LLDPDU_SIZE, GFP_KERNEL);
 			if (!buff)
 				goto command_write_done;
@@ -1659,9 +1659,9 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 			kfree(buff);
 			buff = NULL;
 		} else if (strncmp(&cmd_buf[5], "get remote", 10) == 0) {
+			u16 llen, rlen;
 			int ret, i;
 			u8 *buff;
-			u16 llen, rlen;
 			buff = kzalloc(I40E_LLDPDU_SIZE, GFP_KERNEL);
 			if (!buff)
 				goto command_write_done;
-- 
1.8.3.1
