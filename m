From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net 0/2] enic: Bug fixes
Date: Sun, 19 Oct 2014 14:20:26 +0530
Message-ID: <1413708628-25690-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.200]:53970 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750846AbaJSIuu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Oct 2014 04:50:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series fixes the following problem.

Please apply this to net.

Govindarajulu Varadarajan (2):
  enic: fix possible deadlock in enic_stop/ enic_rfs_flw_tbl_free
  enic: Do not call napi_disable when preemption is disabled.

 drivers/net/ethernet/cisco/enic/enic_clsf.c | 12 ++++++------
 drivers/net/ethernet/cisco/enic/enic_main.c |  4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

-- 
2.1.0
