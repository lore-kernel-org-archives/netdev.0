From: Sriharsha Basavapatna <sriharsha.basavapatna@emulex.com>
Subject: [PATCH net-next 0/4] be2net patch-set
Date: Sun, 15 Feb 2015 13:15:23 +0530
Message-ID: <1423986327-10069-1-git-send-email-sriharsha.basavapatna@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:53223 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754864AbbBOHx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 02:53:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch set contains a few code refactoring changes to make it easy to
support new TX WRB formats in future ASICs. Please consider applying it to
net-next tree.

Patch 1: Refactors chip specific code to setup tx wrb into a separate routine.
Patch 2: Refactors tx enqueue function to remove a bit of duplicate code and
	 improves wrb setup steps.
Patch 3: Minor refactoring in tx compl to limit CQE accesses to 1 routine.
Patch 4: Adds a few inline functions.

Sriharsha Basavapatna (4):
  be2net: Refactor wrb_fill_hdr() routine
  be2net: Refactor be_xmit_enqueue() routine
  be2net: Minor code cleanup in tx completion process
  be2net: Add a few inline functions to test TXQ conditions

 drivers/net/ethernet/emulex/benet/be.h      |  40 ++++
 drivers/net/ethernet/emulex/benet/be_main.c | 295 ++++++++++++++++++----------
 2 files changed, 232 insertions(+), 103 deletions(-)

-- 
2.2.0.65.g9abc44b
