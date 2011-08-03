From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/6] be2net: fixes
Date: Wed, 3 Aug 2011 11:27:40 +0530
Message-ID: <1312351066-16745-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:24506 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754400Ab1HCF4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 01:56:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (6):
  be2net: remove wrong and unnecessary calls to netif_carrier_off()
  be2net: no need to query link status
  be2net: non-member vlan pkts not received in promiscous mode
  be2net: use RX_FILTER cmd to program multicast addresses
  be2net: add support for flashing Teranetics PHY firmware
  be2net: drop pkts that do not belong to the port

 drivers/net/benet/be.h         |    8 ++-
 drivers/net/benet/be_cmds.c    |  140 +++++++++++++-----------------------
 drivers/net/benet/be_cmds.h    |   38 ++++------
 drivers/net/benet/be_ethtool.c |   32 ++-------
 drivers/net/benet/be_hw.h      |   21 ++++--
 drivers/net/benet/be_main.c    |  155 ++++++++++++++++++++++++----------------
 6 files changed, 185 insertions(+), 209 deletions(-)

-- 
1.7.4

