From: Aaron Brown <aaron.f.brown@intel.com>
Subject: [net-next 0/6] Intel Wired LAN Driver Updates
Date: Tue, 14 Jan 2014 00:49:48 -0800
Message-ID: <1389689394-22369-1-git-send-email-aaron.f.brown@intel.com>
Cc: Aaron Brown <aaron.f.brown@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:37134 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750959AbaANIto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 03:49:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to i40e that are primarily minor fixes or 
general cleanup.

Shannon fixes a bug where the VMDq queue is not associated with the
right setup within the hardware.

Mitch provides a patch adjusting where the VF is reset and another
one adding meaningful context to a message.

Jesse cleans up white space comments and parenthesis.  

Catherine bumps the version.

Mitch Williams (2):
  1/6 i40e: remove extra register write
  3/6 i40e: make message meaningful

Shannon Nelson (1):
  2/6 i40e: associate VMDq queue with VM type

Jesse Brandeburg (2):
  4/6 i40e: whitespace fixes
  5/6 i40e: trivial cleanup

Catherine Sullivan (1):
  6/6 i40e: Bump version number

 drivers/net/ethernet/intel/i40e/Module.symvers     |  0
 drivers/net/ethernet/intel/i40e/i40e.h             |  1 -
 drivers/net/ethernet/intel/i40e/i40e_adminq_cmd.h  |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_common.c      |  1 -
 drivers/net/ethernet/intel/i40e/i40e_lan_hmc.c     |  3 +--
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 10 ++++++----
 drivers/net/ethernet/intel/i40e/i40e_txrx.c        |  4 ++--
 drivers/net/ethernet/intel/i40e/i40e_type.h        |  1 +
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c |  6 +++---
 9 files changed, 15 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/i40e/Module.symvers

-- 
1.8.5.GIT
