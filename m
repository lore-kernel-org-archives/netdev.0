From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 0/3] be2net fixes
Date: Thu, 2 May 2013 19:06:14 +0530
Message-ID: <d4e5f897-f081-4b3d-aad0-6ea296cae6db@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:18883 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758008Ab3EBNh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 May 2013 09:37:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply

Kalesh AP (2):
  be2net: Fix firmware download for Lancer
  be2net: avoid napi_disable() when it has not been enabled

Somnath Kotur (1):
  be2net: Fix to fail probe if MSI-X enable fails for a VF

 drivers/net/ethernet/emulex/benet/be.h         |    1 +
 drivers/net/ethernet/emulex/benet/be_cmds.c    |    2 +-
 drivers/net/ethernet/emulex/benet/be_main.c    |   24 ++++++++++++-------
 4 files changed, 25 insertions(+), 17 deletions(-)
