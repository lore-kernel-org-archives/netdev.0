From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net 0/2] bnx2x: ethtool dump fixes
Date: Mon,  1 Jul 2013 17:23:04 +0200
Message-ID: <1372692186-31032-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, Miriam Shitrit <miris@broadcom.com>,
	Yuval Mintz <yuvalmin@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751760Ab3GAPXL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Jul 2013 11:23:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a couple of crashers in bnx2x's ethtool dump implementation.

Michal Schmidt (2):
  bnx2x: remove zeroing of dump data buffer
  bnx2x: fix dump flag handling

 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 5 +++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c    | 2 ++
 2 files changed, 5 insertions(+), 2 deletions(-)

-- 
1.8.1.4
