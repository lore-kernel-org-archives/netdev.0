From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 00/19] bna: clean-up
Date: Wed, 10 Jun 2015 18:43:06 +0200
Message-ID: <1433954605-22813-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40795 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752151AbbFJQm6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jun 2015 12:42:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patches clean the bna driver.

Ivan Vecera (19):
  bna: use ether_addr_copy instead of memcpy
  bna: get rid of mac_t
  bna: replace pragma(pack) with attribute __packed
  bna: get rid of duplicate and unused macros
  bna: use BIT(x) instead of (1 << x)
  bna: remove unused cbfn parameter
  bna: remove pause_cbfn from struct bna_enet
  bna: remove oper_state_cbfn from struct bna_rxf
  bna: remove prio_change_cbfn oper_state_cbfn from struct bna_tx
  bna: remove RXF_E_PAUSE and RXF_E_RESUME events
  bna: remove paused from bna_rx_config and flags from bna_rxf
  bna: remove TX_E_PRIO_CHANGE event and BNA_TX_F_PRIO_CHANGED flag
  bna: correct comparisons/assignments to bool
  bna: use memdup_user to copy userspace buffers
  bna: remove useless pointer assignment
  bna: get rid of private macros for manipulation with lists
  bna: use list_for_each_entry where appropriate
  bna: fix timeout API argument type
  bna: use netdev_* and dev_* instead of printk and pr_*

 drivers/net/ethernet/brocade/bna/bfa_cee.c         |   1 -
 drivers/net/ethernet/brocade/bna/bfa_cs.h          |  14 -
 drivers/net/ethernet/brocade/bna/bfa_defs.h        |  11 +-
 drivers/net/ethernet/brocade/bna/bfa_defs_cna.h    |  16 +-
 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   8 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         |  61 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.h         |  23 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      |   2 +-
 drivers/net/ethernet/brocade/bna/bfa_msgq.c        |  10 +-
 drivers/net/ethernet/brocade/bna/bfi.h             |  84 ++-
 drivers/net/ethernet/brocade/bna/bfi_cna.h         |  30 +-
 drivers/net/ethernet/brocade/bna/bfi_enet.h        | 176 +++---
 drivers/net/ethernet/brocade/bna/bna.h             | 186 +-----
 drivers/net/ethernet/brocade/bna/bna_enet.c        | 101 +---
 drivers/net/ethernet/brocade/bna/bna_hw_defs.h     |  70 +--
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       | 665 +++++----------------
 drivers/net/ethernet/brocade/bna/bna_types.h       |  19 -
 drivers/net/ethernet/brocade/bna/bnad.c            |  93 ++-
 drivers/net/ethernet/brocade/bna/bnad.h            |   2 +-
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c    |  61 +-
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c    |  15 +-
 drivers/net/ethernet/brocade/bna/cna.h             |  62 --
 drivers/net/ethernet/brocade/bna/cna_fwimg.c       |   2 +-
 23 files changed, 487 insertions(+), 1225 deletions(-)

-- 
2.3.6
