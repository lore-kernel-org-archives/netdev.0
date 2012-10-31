From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 0/7] bnx2x: fixes
Date: Wed, 31 Oct 2012 17:46:51 +0200
Message-ID: <1351698418-10005-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>
To: ariele@broadcom.com, eilong@broadcom.com, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2865 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757728Ab2JaPrO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2012 11:47:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave

Please consider applying the series of fixes to net.


Dmitry Kravkov (1):
      bnx2x: disable FCoE for 57840 since not yet supported by FW

Yaniv Rosner (6):
      bnx2x: Fix 57810 1G-KR link against certain switches.
      bnx2x: Fix link down in 57712 following LFA
      bnx2x: Restore global registers back to default.
      bnx2x: Fix potential incorrect link speed provision
      bnx2x: Fix unrecognized SFP+ module after driver is loaded
      bnx2x: Fix no link on 577xx 10G-baseT

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |  158 +++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   10 ++-
 2 files changed, 122 insertions(+), 46 deletions(-)

Thanks,
Dmitry
