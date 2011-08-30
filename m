From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH 0/7 net-next] bnx2x: cleanups and VLAN stripping toggle
Date: Tue, 30 Aug 2011 16:30:39 +0200
Message-ID: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
Cc: vladz@broadcom.com, dmitry@broadcom.com, eilong@broadcom.com,
	Michal Schmidt <mschmidt@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754020Ab1H3ObE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Aug 2011 10:31:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,
patches 1-6 are cleanups.
Patch 7 adds HW VLAN stripping control via ethtool.

Michal Schmidt (7):
  bnx2x: remove unused fields in struct bnx2x_func_init_params
  bnx2x: remove the 'leading' arguments
  bnx2x: decrease indentation in bnx2x_rx_int()
  bnx2x: simplify TPA sanity check
  bnx2x: do not set TPA flags and features in bnx2x_init_bp
  bnx2x: move fp->disable_tpa to ->flags
  bnx2x: expose HW RX VLAN stripping toggle

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   21 +--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  242 +++++++++++-----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h  |    6 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   62 ++----
 4 files changed, 148 insertions(+), 183 deletions(-)

-- 
1.7.6
