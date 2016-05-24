From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 3/3] Documentation: networking: dsa: Describe port_vlan_filtering
Date: Mon, 23 May 2016 21:32:17 -0700
Message-ID: <1464064337-8743-4-git-send-email-f.fainelli@gmail.com>
References: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:36517 "EHLO
	mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716AbcEXEcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2016 00:32:32 -0400
Received: by mail-oi0-f67.google.com with SMTP id x130so1291252oia.3
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 21:32:32 -0700 (PDT)
In-Reply-To: <1464064337-8743-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Described what the port_vlan_filtering function is supposed to
accomplish.

Fixes: fb2dabad69f0 ("net: dsa: support VLAN filtering switchdev attr")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 Documentation/networking/dsa/dsa.txt | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/networking/dsa/dsa.txt b/Documentation/networking/dsa/dsa.txt
index 411b57fd73aa..a42fd2ec32a5 100644
--- a/Documentation/networking/dsa/dsa.txt
+++ b/Documentation/networking/dsa/dsa.txt
@@ -535,6 +535,12 @@ Bridge layer
 Bridge VLAN filtering
 ---------------------
 
+- port_vlan_filtering: bridge layer function invoked when the bridge gets
+  configured for turning on or off VLAN filtering. If nothing specific needs to
+  be done at the hardware level, 0 must be returned. When VLAN filtering is
+  turned on, the hardware must be programmed with rejecting non-802.1Q frames,
+  when turned off the switch must accept any 802.1Q frames.
+
 - port_vlan_prepare: bridge layer function invoked when the bridge prepares the
   configuration of a VLAN on the given port. If the operation is not supported
   by the hardware, this function should return -EOPNOTSUPP to inform the bridge
-- 
2.7.4
