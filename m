From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 0/3] tg3: add support for Ethernet core in BCM4785
Date: Sat, 12 Jan 2013 21:01:42 +0100
Message-ID: <1358020905-9924-1-git-send-email-hauke@hauke-m.de>
Cc: mcarlson@broadcom.com, mchan@broadcom.com, netdev@vger.kernel.org,
	m@bues.ch, Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:55489 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754147Ab3ALUHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2013 15:07:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are adding support for the Ethernet core found in the BCM4705/BCM4785 SoC.

Hauke Mehrtens (3):
  ssb: add missing method ssb_gige_get_macaddr
  tg3: make it possible to provide phy_id in ioctl
  tg3: add support for Ethernet core in bcm4785

 drivers/net/ethernet/broadcom/tg3.c |  137 +++++++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/tg3.h |    5 ++
 include/linux/pci_ids.h             |    1 +
 include/linux/ssb/ssb_driver_gige.h |    3 +
 4 files changed, 133 insertions(+), 13 deletions(-)

-- 
1.7.10.4
