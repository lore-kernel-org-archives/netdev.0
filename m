From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 00/17] remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:13 +0100
Message-ID: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60836 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaC2L0s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As per http://marc.info/?l=linux-netdev&m=139440579104701.

Francois Romieu (17):
  atl1: remove open-coded skb_cow_head.
  atl1c: remove open-coded skb_cow_head.
  atl1e: remove open-coded skb_cow_head.
  igb: remove open-coded skb_cow_head.
  ixgb: remove open-coded skb_cow_head.
  ixgbvf: remove open-coded skb_cow_head.
  ixgbe: remove open-coded skb_cow_head.
  ixgbevf: remove open-coded skb_cow_head.
  e1000: remove open-coded skb_cow_head.
  e1000e: remove open-coded skb_cow_head.
  i40e: remove open-coded skb_cow_head.
  i40evf: remove open-coded skb_cow_head.
  jme: remove open-coded skb_cow_head.
  qlge: remove open-coded skb_cow_head.
  bna: remove open-coded skb_cow_head.
  tg3: remove open-coded skb_cow_head.
  wimax/i2400m: remove open-coded skb_cow_head.

 drivers/net/ethernet/atheros/atl1c/atl1c_main.c   | 14 +++++++-------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c   | 14 +++++++-------
 drivers/net/ethernet/atheros/atlx/atl1.c          | 15 +++++++--------
 drivers/net/ethernet/broadcom/tg3.c               |  3 +--
 drivers/net/ethernet/brocade/bna/bnad.c           | 10 ++++------
 drivers/net/ethernet/intel/e1000/e1000_main.c     | 11 +++++------
 drivers/net/ethernet/intel/e1000e/netdev.c        | 10 ++++------
 drivers/net/ethernet/intel/i40e/i40e_txrx.c       | 18 +++++++++---------
 drivers/net/ethernet/intel/i40evf/i40e_txrx.c     | 10 ++++------
 drivers/net/ethernet/intel/igb/igb_main.c         |  9 ++++-----
 drivers/net/ethernet/intel/igbvf/netdev.c         | 16 +++++++---------
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |  9 ++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     | 13 ++++++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  9 ++++-----
 drivers/net/ethernet/jme.c                        | 16 ++--------------
 drivers/net/ethernet/qlogic/qlge/qlge_main.c      |  9 ++++-----
 drivers/net/wimax/i2400m/netdev.c                 |  3 +--
 17 files changed, 80 insertions(+), 109 deletions(-)

-- 
1.9.0
