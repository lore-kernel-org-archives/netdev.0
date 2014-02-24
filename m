From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH 0/5] be2net patches
Date: Mon, 24 Feb 2014 12:16:57 +0530
Message-ID: <5d7a827c-b95c-4f9c-9a93-5518326b36ce@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8429 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaBXGsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 01:48:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Somnath Kotur (1):
  be2net: Fix to reset transparent vlan tagging

Somnath kotur (1):
  be2net: clear promiscuous bits in adapter->flags while disabling
    promiscuous mode

Vasundhara Volam (3):
  be2net: Fix skb double free in be_xmit_wrokarounds() failure path
  be2net: wait longer to reap TX compls in be_close()
  be2net: isolate TX workarounds not applicable to Skyhawk-R

 drivers/net/ethernet/emulex/benet/be.h      |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   89 +++++++++++++++-----------
 2 files changed, 54 insertions(+), 39 deletions(-)
