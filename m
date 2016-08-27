From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH] Documentation: networking: dsa: Remove platform device TODO
Date: Sat, 27 Aug 2016 15:34:20 -0700
Message-ID: <1472337260-7467-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:35505 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754209AbcH0We0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 Aug 2016 18:34:26 -0400
Received: by mail-oi0-f66.google.com with SMTP id e80so9555748oig.2
        for <netdev@vger.kernel.org>; Sat, 27 Aug 2016 15:34:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since commit 83c0afaec7b7 ("net: dsa: Add new binding implementation"),
the shortcomings of the dsa platform device have been addressed, remove
that TODO item.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/dsa/dsa.txt | 20 --------------------
 1 file changed, 20 deletions(-)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 44ed453ccf66..a4e55c76d371 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -587,26 +587,6 @@ of DSA, would be the its port-based VLAN, used by the associated bridge device.
 TODO
 ====
 
-The platform device problem
----------------------------
-DSA is currently implemented as a platform device driver which is far from ideal
-as was discussed in this thread:
-
-http://permalink.gmane.org/gmane.linux.network/329848
-
-This basically prevents the device driver model to be properly used and applied,
-and support non-MDIO, non-MMIO Ethernet connected switches.
-
-Another problem with the platform device driver approach is that it prevents the
-use of a modular switch drivers build due to a circular dependency, illustrated
-here:
-
-http://comments.gmane.org/gmane.linux.network/345803
-
-Attempts of reworking this has been done here:
-
-https://lwn.net/Articles/643149/
-
 Making SWITCHDEV and DSA converge towards an unified codebase
 -------------------------------------------------------------
 
-- 
2.7.4
