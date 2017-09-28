From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH ethtool 2/2] ethtool.8: Document 56000 advertise link modes
Date: Thu, 28 Sep 2017 15:08:53 +0300
Message-ID: <1506600533-10365-3-git-send-email-galp@mellanox.com>
References: <1506600533-10365-1-git-send-email-galp@mellanox.com>
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Pavel Belous <pavel.s.belous@gmail.com>,
        Gal Pressman <galp@mellanox.com>
To: netdev@vger.kernel.org,
        "John W . Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53420 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751906AbdI1MJZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 08:09:25 -0400
In-Reply-To: <1506600533-10365-1-git-send-email-galp@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the following advertise modes to the manual:
56000baseKR4 Full
56000baseCR4 Full
56000baseSR4 Full
56000baseLR4 Full

Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
---
 ethtool.8.in | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index de2abc8..1654c73 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -613,6 +613,10 @@ lB	l	lB.
 0x400000000	50000baseCR2 Full
 0x800000000	50000baseKR2 Full
 0x10000000000	50000baseSR2 Full
+0x8000000	56000baseKR4 Full
+0x10000000	56000baseCR4 Full
+0x20000000	56000baseSR4 Full
+0x40000000	56000baseLR4 Full
 0x1000000000	100000baseKR4 Full
 0x2000000000	100000baseSR4 Full
 0x4000000000	100000baseCR4 Full
-- 
2.7.4
