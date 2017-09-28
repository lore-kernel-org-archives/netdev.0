From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH ethtool 1/2] ethtool.8: Fix formatting of advertise bitmask
Date: Thu, 28 Sep 2017 15:08:52 +0300
Message-ID: <1506600533-10365-2-git-send-email-galp@mellanox.com>
References: <1506600533-10365-1-git-send-email-galp@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Pavel Belous <pavel.s.belous@gmail.com>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53416 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751768AbdI1MJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 08:09:25 -0400
In-Reply-To: <1506600533-10365-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fields should be separated with a tab instead of spaces.
Also, remove an accidental ' character from 2500baseX Full mode.

Fixes: 64dfc5e2f046 ("ethtool: Add support for 2500baseT/5000baseT link modes")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 ethtool.8.in | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7224b04..de2abc8 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -590,9 +590,9 @@ lB	l	lB.
 0x020	1000baseT Full
 0x20000	1000baseKX Full
 0x20000000000	1000baseX Full
-0x800000000000  2500baseT Full
-0x8000	2500baseX Full	(not supported by IEEE standards)'
-0x1000000000000  5000baseT Full
+0x800000000000	2500baseT Full
+0x8000	2500baseX Full	(not supported by IEEE standards)
+0x1000000000000	5000baseT Full
 0x1000	10000baseT Full
 0x40000	10000baseKX4 Full
 0x80000	10000baseKR Full
-- 
2.7.4
