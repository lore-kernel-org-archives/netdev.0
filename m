From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 0/3] i40e: fix MSI-X vector allocation for > 128 CPU threads
Date: Mon, 19 Sep 2016 13:37:48 +0200
Message-ID: <1474285071-28218-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53790 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755883AbcISLiU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 07:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Assmann (3):
  i40e: check if vectors are already depleted when doing VMDq allocation
  i40e: fix MSI-X vector redistribution if hw limit is reached
  i40e: fix sideband flow director vector allocation

 drivers/net/ethernet/intel/i40e/i40e_main.c | 76 ++++++++++++++++++-----------
 1 file changed, 47 insertions(+), 29 deletions(-)

-- 
2.7.4
