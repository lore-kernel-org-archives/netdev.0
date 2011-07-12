From: Andre Heider <a.heider@gmail.com>
Subject: [PATCH 0/3] ps3_gelic: Fix error paths when a tx dma fails
Date: Tue, 12 Jul 2011 22:13:23 +0200
Message-ID: <1310501606-829-1-git-send-email-a.heider@gmail.com>
Cc: netdev@vger.kernel.org, cbe-oss-dev@lists.ozlabs.org,
	Andre Heider <a.heider@gmail.com>
To: Geoff Levand <geoff@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:45807 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753680Ab1GLUNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 16:13:45 -0400
Received: by bwd5 with SMTP id 5so4318012bwd.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 13:13:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes a few bugs for the error paths once a tx dma request
fails. Without these I either ran into BUG_ON, the device got killed,
or the kernel crashed.

Note about #2:
I'm not sure what "gelic_descr_release_tx(card, descr->next)"
was doing there, ->next was never touched. Did i miss something?

Andre Heider (3):
  ps3_gelic: Fix typos
  ps3_gelic: Fix start_xmit kick error path
  ps3_gelic: Don't kill the device on DMA failure

 drivers/net/ps3_gelic_net.c |   20 +++++++++++++-------
 1 files changed, 13 insertions(+), 7 deletions(-)

-- 
1.7.5.4

