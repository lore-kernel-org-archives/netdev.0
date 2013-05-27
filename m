From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 0/3] be2net fixes
Date: Mon, 27 May 2013 12:27:10 +0530
Message-ID: <967ba7af-9de5-4d61-96b9-c5e2bc2cf582@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:5375 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756547Ab3E0G6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 02:58:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Somnath Kotur (3):
  be2net: cleanup be_get_drvinfo()
  be2net: Pad skb to meet minimum Tx pkt size in lancer
  be2net: Trim padded packets for Lancer

 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    8 ++------
 drivers/net/ethernet/emulex/benet/be_main.c    |   20 ++++++++++++++++++--
 3 files changed, 21 insertions(+), 8 deletions(-)
