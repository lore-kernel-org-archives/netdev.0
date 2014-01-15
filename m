From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/3] Intel Wired LAN Driver Updates
Date: Wed, 15 Jan 2014 15:18:21 -0800
Message-ID: <1389827904-14713-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33902 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbaAOXSd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:18:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e from Shannon Nelson.  The first 
removes a mistaken file that I apparently introduced as part of a 
branch merge / update.  Second checks that descritors were allocated
before printing and makes the code a bit easier to read.  Finally he 
refines cloud support in the Firmware API.

Shannon Nelson (3): 
  i40e: remove mistaken file  
  i40e: check desc pointer before printing
  i40e: updates to AdminQ interface

 drivers/net/ethernet/intel/i40e/Module.symvers    |  0
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h | 22 +++-----
 drivers/net/ethernet/intel/i40e/i40e_common.c     |  1 -
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c    | 67 +++++++++++++----------
 4 files changed, 47 insertions(+), 43 deletions(-)
 delete mode 100644 drivers/net/ethernet/intel/i40e/Module.symvers

-- 
1.8.5.GIT
