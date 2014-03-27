From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 14/14] Documentation: networking: phy.txt: MDIO bus reset is optional
Date: Wed, 26 Mar 2014 18:07:26 -0700
Message-ID: <1395882446-552-15-git-send-email-f.fainelli@gmail.com>
References: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:56103 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756675AbaC0BIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 21:08:20 -0400
Received: by mail-pa0-f51.google.com with SMTP id kq14so2695222pab.24
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 18:08:20 -0700 (PDT)
In-Reply-To: <1395882446-552-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the MDIO bus documentation to mention that the MDIO bus reset
function is completely optional. It became optional with commit
e13934563db0 ("[PATCH] PHY Layer fixup")

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/phy.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
index e602c6f347df..3544c98401fd 100644
--- a/Documentation/networking/phy.txt
+++ b/Documentation/networking/phy.txt
@@ -48,7 +48,7 @@ The MDIO bus
    time, so it is safe for them to block, waiting for an interrupt to signal
    the operation is complete
  
- 2) A reset function is necessary.  This is used to return the bus to an
+ 2) A reset function is optional.  This is used to return the bus to an
    initialized state.
 
  3) A probe function is needed.  This function should set up anything the bus
-- 
1.8.3.2
