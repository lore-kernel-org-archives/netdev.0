From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH ethtool 3/3] ethtool: Document new ethtool advertise speeds
Date: Mon, 22 Aug 2016 08:50:39 +0300
Message-ID: <1471845039-28718-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vidya@cumulusnetworks.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <netdev@vger.kernel.org>, <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39418 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754340AbcHVFv1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 01:51:27 -0400
In-Reply-To: <1471845039-28718-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
This is actually quite a horrible API - i.e., forcing the user to use
the same bits as defined in ethtool-copy.h instead of having some sort
of translation. But as these issues are already existing with current
modes [==> can't be changed without breaking backward compatibility]
I've continued doing the same.
---
 ethtool.8.in | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/ethtool.8.in b/ethtool.8.in
index 9269a8d..821d0bc 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -581,10 +581,20 @@ lB	l	lB.
 0x80000	10000baseKR Full
 0x200000	20000baseMLD2 Full	(not supported by IEEE standards)
 0x400000	20000baseKR2 Full	(not supported by IEEE standards)
+0x80000000	25000baseCR Full
+0x100000000	25000baseKR Full
+0x200000000	25000baseSR Full
 0x800000	40000baseKR4 Full
 0x1000000	40000baseCR4 Full
 0x2000000	40000baseSR4 Full
 0x4000000	40000baseLR4 Full
+0x400000000	50000baseCR2 Full
+0x800000000	50000baseKR2 Full
+0x10000000000	50000baseSR2 Full
+0x1000000000	100000baseKR4 Full
+0x2000000000	100000baseSR4 Full
+0x4000000000	100000baseCR4 Full
+0x8000000000	100000baseLR4_ER4 Full
 .TE
 .TP
 .BI phyad \ N
-- 
1.9.3
