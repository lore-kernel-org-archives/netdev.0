From: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>
Subject: [PATCH v2 0/2] checkpatch: new ethernet address manipulation checks
Date: Mon, 20 Apr 2015 00:16:54 +0200
Message-ID: <1429481816-6664-1-git-send-email-mateusz.kulikowski@gmail.com>
Cc: Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com, apw@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f179.google.com ([209.85.217.179]:34584 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751158AbbDSWRE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Apr 2015 18:17:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes in v2 (applied review comments):
- Fixed indentation in both patches
- Detect memset(foo, 0x00, ETH_ALEN)
- Detect memset(foo, 255, ETH_ALEN)
- Rephrased 2/2 commit message

Patch Notes from v1:
Add 3 new warnings to checkpatch:
1) PREFER_ETHER_ADDR_EQUAL 
Replace memcmp(foo, bar, ETH_ALEN) with ether_addr_equal*()
2) PREFER_ETH_ZERO_ADDR
Replace memset(foo, 0, ETH_ALEN) with eth_zero_addr()
3) PREFER_ETH_BROADCAST_ADDR
Replace memset(foo, 0xFF, ETH_ALEN) with eth_broadcast_addr()


Mateusz Kulikowski (2):
  checkpatch: suggest using ether_addr_equal*()
  checkpatch: suggest using eth_zero_addr() and eth_broadcast_addr()

 scripts/checkpatch.pl | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

-- 
1.8.4.1
