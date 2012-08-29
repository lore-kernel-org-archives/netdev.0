From: Sathya Perla <sathya.perla@emulex.com>
Subject: [net-next PATCH 0/5] be2net fixes
Date: Wed, 29 Aug 2012 12:07:39 +0530
Message-ID: <68712d56-8bf1-48bf-9408-4a5081ea17ee@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46266 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab2H2G4q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 02:56:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (2):
  be2net: create RSS rings even in multi-channel configs
  be2net: fixup malloc/free of adapter->pmac_id

Vasundhara Volam (3):
  be2net: fix max VFs reported by HW
  be2net: fix FW default for VF tx-rate
  be2net: modify log msg for lack of privilege error

 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   22 ++++++++++++----------
 3 files changed, 14 insertions(+), 11 deletions(-)

-- 
1.7.4
