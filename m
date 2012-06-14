From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH 0/3] be2net: patches fix max gso size, modify driver log info and stats struct.
Date: Thu, 14 Jun 2012 11:21:42 +0530
Message-ID: <8b01e121-64f5-4a7a-ace5-2f811b097a8d@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51758 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750974Ab2FNFwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 01:52:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Please apply these patches. Thanks.

Sarveshwar Bandi (1):
  be2net: reduce gso_max_size setting to account for ethernet header.

Vasundhara Volam (2):
  be2net: Modify error message to incorporate subsystem
  be2net: Increase statistics structure size for skyhawk.

 drivers/net/ethernet/emulex/benet/be_cmds.c |   12 ++++++------
 drivers/net/ethernet/emulex/benet/be_cmds.h |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c |    2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

-- 
1.7.9.5
