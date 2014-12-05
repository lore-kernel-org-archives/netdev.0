From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH net-next ] Documentation (ixgbe.txt): use a decimal address.
Date: Fri,  5 Dec 2014 19:35:43 +0200
Message-ID: <1417800943-4429-1-git-send-email-ramirose@gmail.com>
Cc: netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com,
	Rami Rosen <ramirose@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:35202 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751018AbaLERfz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Dec 2014 12:35:55 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so2097958wiv.4
        for <netdev@vger.kernel.org>; Fri, 05 Dec 2014 09:35:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the erronous usage of an hexadecimal address in the 
example, by replacing it with a decimal address.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 Documentation/networking/ixgbe.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/Documentation/networking/ixgbe.txt b/Documentation/networking/ixgbe.txt
index 96ccceb..0ace6e7 100644
--- a/Documentation/networking/ixgbe.txt
+++ b/Documentation/networking/ixgbe.txt
@@ -138,7 +138,7 @@ Other ethtool Commands:
 To enable Flow Director
 	ethtool -K ethX ntuple on
 To add a filter
-	Use -U switch. e.g., ethtool -U ethX flow-type tcp4 src-ip 0x178000a
+	Use -U switch. e.g., ethtool -U ethX flow-type tcp4 src-ip 10.0.128.23
         action 1
 To see the list of filters currently present:
 	ethtool -u ethX
-- 
1.9.0
