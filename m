From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 00/13] Cleanup patches for the SFC driver
Date: Wed, 12 Feb 2014 18:56:02 +0000
Message-ID: <52FBC3C2.7030103@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:50882 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752831AbaBLS4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Feb 2014 13:56:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set consists of some cleanup and housekeeping
patches for the sfc driver.
These patches help to reduce the differences between the in-
tree and out-of-tree driver.

Ben Hutchings (12):
  sfc: Cache skb->data in local variable in efx_ptp_rx()
  sfc: Rewrite adjustment of PPS event in a clearer way
  sfc: Replace TSOH_OFFSET with the equivalent NET_IP_ALIGN
  sfc: Rename 'use_options' variable in tso_start() to clearer
    'use_opt_desc'
  sfc: Remove unused definitions of EF10 user-mode DMA descriptors
  sfc: Correct comment about number of TX queues used on EF10
  sfc: Preserve rx_frm_trunc counters when resizing DMA rings
  sfc: Use canonical pointer type for MAC address in
    efx_set_mac_address()
  sfc: Update product naming
  sfc: Cosmetic changes to self-test from the out-of-tree driver
  sfc: Fail self-test with -EBUSY, not -EIO, if the device is busy
  sfc: Add/remove blank lines to taste

Laurence Evans (1):
  sfc: Removed adhoc scheme to rate limit PTP event queue overflow
    message

 drivers/net/ethernet/sfc/ef10.c       |    4 +-
 drivers/net/ethernet/sfc/ef10_regs.h  |   61 ----------------------
 drivers/net/ethernet/sfc/efx.c        |    6 +--
 drivers/net/ethernet/sfc/efx.h        |    2 +-
 drivers/net/ethernet/sfc/ethtool.c    |   21 +++++---
 drivers/net/ethernet/sfc/falcon.c     |    4 +-
 drivers/net/ethernet/sfc/farch.c      |    2 -
 drivers/net/ethernet/sfc/net_driver.h |    1 -
 drivers/net/ethernet/sfc/nic.c        |    1 -
 drivers/net/ethernet/sfc/ptp.c        |   92 ++++++++++++++-------------------
 drivers/net/ethernet/sfc/tx.c         |   21 ++-----
 11 files changed, 65 insertions(+), 150 deletions(-)
