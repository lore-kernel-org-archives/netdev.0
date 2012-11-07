From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/7] be2net: patch set
Date: Wed, 7 Nov 2012 09:18:54 +0530
Message-ID: <4f3dfb12-ef85-48ce-9c67-f5e58ed6f105@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:46374 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753223Ab2KGDqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2012 22:46:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Sathya Perla (7):
  be2net: remove LANCER A0 workaround
  be2net: fix wrong usage of adapter->generation
  be2net: do not use sli_family to identify skyhawk-R chip
  be2net: re-factor bar mapping code
  be2net: fix access to SEMAPHORE reg
  be2net: remove roce on lancer
  be2net: remove adapter->eq_next_idx

 drivers/net/ethernet/emulex/benet/be.h      |   33 ++--
 drivers/net/ethernet/emulex/benet/be_cmds.c |   17 +-
 drivers/net/ethernet/emulex/benet/be_cmds.h |   27 ---
 drivers/net/ethernet/emulex/benet/be_hw.h   |   17 +-
 drivers/net/ethernet/emulex/benet/be_main.c |  280 ++++++++++-----------------
 drivers/net/ethernet/emulex/benet/be_roce.c |    5 +-
 6 files changed, 135 insertions(+), 244 deletions(-)
