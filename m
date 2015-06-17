From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 0/3] bna: clean-up 2
Date: Wed, 17 Jun 2015 18:41:55 +0200
Message-ID: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033AbbFQQlW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 12:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next round of cleaning patches.

Ivan Vecera (3):
  bna: remove unnecessary cast of BIT value
  bna: make pointers to read-only inputs const
  bna: remove superfluous parentheses

 .../net/ethernet/brocade/bna/bfa_defs_mfg_comm.h   |   2 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc.c         |  10 +-
 drivers/net/ethernet/brocade/bna/bfa_ioc_ct.c      | 101 ++++++++++-----------
 drivers/net/ethernet/brocade/bna/bna.h             |  19 ++--
 drivers/net/ethernet/brocade/bna/bna_enet.c        |   4 +-
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c       |  18 ++--
 drivers/net/ethernet/brocade/bna/bnad.c            |  18 ++--
 drivers/net/ethernet/brocade/bna/bnad.h            |   2 +-
 drivers/net/ethernet/brocade/bna/bnad_debugfs.c    |   6 +-
 9 files changed, 89 insertions(+), 91 deletions(-)

-- 
2.3.6
