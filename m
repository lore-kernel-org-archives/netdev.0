From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 0/3] be2net fixes
Date: Thu, 5 Dec 2013 10:34:00 +0530
Message-ID: <72e434bb-7c52-4dbe-a406-c6e0ad49e909@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:49634 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711Ab3LEFF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 00:05:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Somnath Kotur (3):
  be2net: Fix Lancer error recovery to distinguish FW download
  be2net: Log a kernel message when the user tries to configure more
    Multicast addresses than supported
  be2net: Free/delete pmacs (in be_clear()) only if they exist

 drivers/net/ethernet/emulex/benet/be.h      |    1 +
 drivers/net/ethernet/emulex/benet/be_hw.h   |    3 +
 drivers/net/ethernet/emulex/benet/be_main.c |   72 +++++++++++++++++++-------
 3 files changed, 56 insertions(+), 20 deletions(-)
