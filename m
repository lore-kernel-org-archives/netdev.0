From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v3 0/3] tg3: add support for Ethernet core in BCM4785
Date: Wed,  6 Feb 2013 23:46:05 +0100
Message-ID: <1360190768-390-1-git-send-email-hauke@hauke-m.de>
Cc: mcarlson@broadcom.com, mchan@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:36055 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755294Ab3BFWqX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 17:46:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are adding support for the Ethernet core found in the 
BCM4705/BCM4785 SoC.

This is based on current master of davem/net-next.git.

v3:
 * combined first two patches into one patch

v2:
 * use of struct sprom in ssb_gige_get_macaddr() instead of accessing 
   the nvram directly
 * add return value to ssb_gige_get_macaddr()
 * try to read the mac address from ssb core before accessing the own 
   registers.
 * fix two checkpatch warnings


Hauke Mehrtens (3):
  ssb: get mac address from sprom struct for gige driver
  tg3: make it possible to provide phy_id in ioctl
  tg3: add support for Ethernet core in bcm4785

 drivers/net/ethernet/broadcom/tg3.c |  144 +++++++++++++++++++++++++++++++----
 drivers/net/ethernet/broadcom/tg3.h |    5 ++
 include/linux/pci_ids.h             |    1 +
 include/linux/ssb/ssb_driver_gige.h |   23 +++---
 4 files changed, 148 insertions(+), 25 deletions(-)

-- 
1.7.10.4
