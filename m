From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next] be2net patches
Date: Wed, 12 Feb 2014 16:07:22 +0530
Message-ID: <ba23fbc6-39a0-4925-890a-6059ab5186a8@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:28885 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbaBLKjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 05:39:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Somnath Kotur (1):
  be2net: This patch logs a kernel message when a HW
    error(SLIPORT_ERROR in Lancer and UE in BEx/Skyhawk)

Vasundhara Volam (2):
  be2net: Update copyright year
  be2net: refactor multi-channel config code for Skyhawk-R chip

 drivers/net/ethernet/emulex/benet/be.h         |   14 ++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   22 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   38 ++++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    2 +-
 drivers/net/ethernet/emulex/benet/be_hw.h      |    6 +-
 drivers/net/ethernet/emulex/benet/be_main.c    |  171 +++++++++++++++---------
 drivers/net/ethernet/emulex/benet/be_roce.c    |    2 +-
 drivers/net/ethernet/emulex/benet/be_roce.h    |    2 +-
 8 files changed, 176 insertions(+), 81 deletions(-)
