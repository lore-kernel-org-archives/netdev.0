From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 0/4] be2net fixes
Date: Tue, 30 Apr 2013 17:05:58 +0530
Message-ID: <c0a64f53-1e44-469d-919c-a5ac4dfc24d8@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:25240 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760303Ab3D3LhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 07:37:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

Pls apply

Kalesh AP (3):
  be2net: Fix firmware download for Lancer
  be2net: Fix ethtool get drvinfo
  be2net: Fix driver hang when RQ create fails

Somnath Kotur (1):
  be2net: Fix to fail probe if MSI-X enable fails for a VF

 drivers/net/ethernet/emulex/benet/be.h         |    2 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    8 +----
 drivers/net/ethernet/emulex/benet/be_main.c    |   30 ++++++++++++++++--------
 4 files changed, 25 insertions(+), 17 deletions(-)
