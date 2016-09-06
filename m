From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
Subject: [ethtool PATCH v1] ethtool: Document  ethtool advertised speeds for 1G/10G
Date: Tue,  6 Sep 2016 16:55:11 -0700
Message-ID: <1473206111-47026-1-git-send-email-vidya@cumulusnetworks.com>
To: linville@tuxdriver.com, netdev@vger.kernel.org, bwh@kernel.org,
        davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:35092 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754944AbcIFXzQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 19:55:16 -0400
Received: by mail-pf0-f172.google.com with SMTP id w87so21329086pfk.2
        for <netdev@vger.kernel.org>; Tue, 06 Sep 2016 16:55:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>

Man page update to include updated advertised speeds for
1G/10G

Signed-off-by: Vidya Sagar Ravipati <vidya@cumulusnetworks.com>
---
 ethtool.8.in | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 821d0bc..376831d 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -575,10 +575,16 @@ lB	l	lB.
 0x010	1000baseT Half	(not supported by IEEE standards)
 0x020	1000baseT Full
 0x20000	1000baseKX Full
+0x20000000000	1000baseX Full
 0x8000	2500baseX Full	(not supported by IEEE standards)
 0x1000	10000baseT Full
 0x40000	10000baseKX4 Full
 0x80000	10000baseKR Full
+0x40000000000	10000baseCR  Full
+0x80000000000	10000baseSR  Full
+0x100000000000	10000baseLR  Full
+0x200000000000	10000baseLRM Full
+0x400000000000	10000baseER  Full
 0x200000	20000baseMLD2 Full	(not supported by IEEE standards)
 0x400000	20000baseKR2 Full	(not supported by IEEE standards)
 0x80000000	25000baseCR Full
-- 
2.1.4
