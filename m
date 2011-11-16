From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 0/5] be2net updates
Date: Wed, 16 Nov 2011 17:31:58 +0530
Message-ID: <3ff176bc-1a62-44d9-a09f-36aa4ee371d9@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:45641 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756452Ab1KPMDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 07:03:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (5):
  be2net: Fix TX queue create for Lancer
  be2net: add register dump feature for Lancer
  be2net: Add EEPROM dump feature for Lancer
  be2net: Fix VLAN promiscous mode for Lancer
  be2net: Use V1 query link status command for lancer

 drivers/net/ethernet/emulex/benet/be_cmds.c    |   65 +++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   36 +++++++++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   95 ++++++++++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_main.c    |   15 +++-
 4 files changed, 196 insertions(+), 15 deletions(-)
