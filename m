From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 2/3] Documentation: dtb: xgene: Add channel property
Date: Fri, 29 Apr 2016 11:10:14 -0700
Message-ID: <1461953415-9741-3-git-send-email-isubramanian@apm.com>
References: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34333 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752603AbcD2SJz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 14:09:55 -0400
Received: by mail-pa0-f46.google.com with SMTP id r5so49201286pag.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 11:09:55 -0700 (PDT)
In-Reply-To: <1461953415-9741-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 Documentation/devicetree/bindings/net/apm-xgene-enet.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
index 078060a..05f705e3 100644
--- a/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
+++ b/Documentation/devicetree/bindings/net/apm-xgene-enet.txt
@@ -18,6 +18,8 @@ Required properties for all the ethernet interfaces:
   - First is the Rx interrupt.  This irq is mandatory.
   - Second is the Tx completion interrupt.
     This is supported only on SGMII based 1GbE and 10GbE interfaces.
+- channel: Ethernet to CPU, start channel (prefetch buffer) number
+  - Must map to the first irq and irqs must be sequential
 - port-id: Port number (0 or 1)
 - clocks: Reference to the clock entry.
 - local-mac-address: MAC address assigned to this device
-- 
1.9.1
