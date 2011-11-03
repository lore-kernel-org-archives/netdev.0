From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/4] be2net fixes and updates
Date: Thu, 3 Nov 2011 17:17:59 +0530
Message-ID: <fafeb93b-224e-46d9-86c3-3aad8a01da36@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:24402 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755767Ab1KCLtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 07:49:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (4):
  be2net: Fix endian issue in RX filter command
  be2net: Fix disabling multicast promiscous mode
  be2net: Prevent CQ full condition for Lancer
  be2net: Add detect UE feature for Lancer

 drivers/net/ethernet/emulex/benet/be_cmds.c |   12 ++++-
 drivers/net/ethernet/emulex/benet/be_hw.h   |    2 +
 drivers/net/ethernet/emulex/benet/be_main.c |   68 +++++++++++++++++---------
 3 files changed, 55 insertions(+), 27 deletions(-)
