From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/2] Intel Wired LAN Driver Updates
Date: Mon, 13 Jan 2014 16:13:02 -0800
Message-ID: <1389658384-15825-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31056 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289AbaANANC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jan 2014 19:13:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e from Greg Rose for VLAN filtering.

Greg Rose (2):
  i40e: Warn admin to reload VF driver on port VLAN configuration.  
    When an administrator sets a port VLAN filters for the virtual
    function (VF) after the VF has already set its own VLAN filters a 
    conflict requiring the VF be reloaded can occur.  This patch logs a
    message indicating to the system administrator that the VF driver 
    must be reloaded for the new port VLAN settings to take effect

  i40e: Retain MAC filters on port VLAN deletion
    On port VLAN deletion the list of MAC filters for the virtual function
    (VF) VSI were all deleted.  Let's keep them around, they come in
    handy for keeping the VF functional.

 drivers/net/ethernet/intel/i40e/i40e_main.c        |  3 +++
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 18 ++++++++++++++++++
 2 files changed, 21 insertions(+)

-- 
1.8.5.GIT
