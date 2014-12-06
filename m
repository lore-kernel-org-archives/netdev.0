From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/16] i40e: allow various base numbers in debugfs aq commands
Date: Sat,  6 Dec 2014 05:02:00 -0800
Message-ID: <1417870933-17248-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:8816 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653AbaLFNC5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 Dec 2014 08:02:57 -0500
In-Reply-To: <1417870933-17248-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

Use the 'i' rather than the more restrictive 'x' or 'd' in the aq_cmd
arguments.  This makes the user interface much more forgiving and user
friendly.

Change-ID: I5dcd57b9befc047e06b74cf1152a25a3fa9e1309
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 3a3c237..16ac3f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -1493,7 +1493,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (!desc)
 			goto command_write_done;
 		cnt = sscanf(&cmd_buf[11],
-			     "%hx %hx %hx %hx %x %x %x %x %x %x",
+			     "%hi %hi %hi %hi %i %i %i %i %i %i",
 			     &desc->flags,
 			     &desc->opcode, &desc->datalen, &desc->retval,
 			     &desc->cookie_high, &desc->cookie_low,
@@ -1541,7 +1541,7 @@ static ssize_t i40e_dbg_command_write(struct file *filp,
 		if (!desc)
 			goto command_write_done;
 		cnt = sscanf(&cmd_buf[20],
-			     "%hx %hx %hx %hx %x %x %x %x %x %x %hd",
+			     "%hi %hi %hi %hi %i %i %i %i %i %i %hi",
 			     &desc->flags,
 			     &desc->opcode, &desc->datalen, &desc->retval,
 			     &desc->cookie_high, &desc->cookie_low,
-- 
1.9.3
