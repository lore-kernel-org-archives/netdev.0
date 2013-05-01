From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 0/4] be2net: Patch series
Date: Wed, 1 May 2013 14:37:07 -0500
Message-ID: <20130501193707.GA3773@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:6201 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756074Ab3EAThL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 15:37:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Ajit Khaparde (4):
  be2net: Fix to use version 2 of cq_create for SkyHawk-R devices
  be2net: Fix to use 32-bit stats to report rx_drops_no_fragment
  be2net: Fix to show tx priority pause counter in ethtool -S
  be2net: Fix to receive Multicast Packets when Promiscuous mode is
    enabled on certain devices

 drivers/net/ethernet/emulex/benet/be_cmds.c    |   33 +++++++++++++-----------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    1 +
 drivers/net/ethernet/emulex/benet/be_main.c    |   24 ++++++++++++-----
 4 files changed, 38 insertions(+), 22 deletions(-)

-- 
1.7.10.4
