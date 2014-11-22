From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/17] i40e: allow various base numbers in debugfs aq commands
Date: Fri, 21 Nov 2014 21:54:54 -0800
Message-ID: <1416635708-4765-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Shannon Nelson <shannon.nelson@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:24551 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750703AbaKVFzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Nov 2014 00:55:13 -0500
In-Reply-To: <1416635708-4765-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
