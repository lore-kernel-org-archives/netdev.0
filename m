From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net v2 0/4] be2net fixes
Date: Mon, 3 Mar 2014 14:24:05 +0530
Message-ID: <07564252-a4d2-43fa-b3b1-41df316f706d@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:47396 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879AbaCCIzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 03:55:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Somnath Kotur (1):
  be2net: Fix to reset transparent vlan tagging

Somnath kotur (1):
  be2net: clear promiscuous bits in adapter->flags while disabling
    promiscuous mode

Vasundhara Volam (2):
  be2net: Fix skb double free in be_xmit_wrokarounds() failure path
  be2net: isolate TX workarounds not applicable to Skyhawk-R

 drivers/net/ethernet/emulex/benet/be.h      |    4 +-
 drivers/net/ethernet/emulex/benet/be_main.c |   84 +++++++++++++++------------
 2 files changed, 50 insertions(+), 38 deletions(-)
