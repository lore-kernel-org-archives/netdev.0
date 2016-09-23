From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next v2 0/2] i40e: clean-up and fix for the i40e debug code
Date: Fri, 23 Sep 2016 15:30:56 +0200
Message-ID: <1474637458-5255-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, carolyn.wyborny@intel.com,
        sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964968AbcIWNbU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 09:31:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 fixes setting the debug_mask in i40e_set_msglevel().

Stefan Assmann (2):
  i40e: remove superfluous I40E_DEBUG_USER statement
  i40e: fix setting debug parameter early

 drivers/net/ethernet/intel/i40e/i40e_common.c  |  3 --
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c |  6 ----
 drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  3 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c    | 43 ++++++++++++--------------
 drivers/net/ethernet/intel/i40e/i40e_type.h    |  2 --
 5 files changed, 21 insertions(+), 36 deletions(-)

-- 
2.7.4
