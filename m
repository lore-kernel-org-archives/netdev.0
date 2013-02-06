From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 0/4] bgmac: fixes and more netdev ops
Date: Wed,  6 Feb 2013 15:44:56 +0100
Message-ID: <1360161900-2330-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:34652 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751118Ab3BFOpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 09:45:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first patch implements a TODO in the driver.
The other patches are fixing or adding some netdev ops.

This is based on current master of davem/net-next.git.

Hauke Mehrtens (4):
  bgmac: implement missing code for BCM53572
  bgmac: write mac address to hardware in ndo_set_mac_address
  bgmac: add generic ndo_validate_addr netdev ops
  bgmac: add ndo_set_rx_mode netdev ops

 drivers/net/ethernet/broadcom/bgmac.c |   56 ++++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/bgmac.h |    2 +-
 2 files changed, 43 insertions(+), 15 deletions(-)

-- 
1.7.10.4
