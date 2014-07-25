From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 1/8] amd-xgbe: Add dma-coherent to device bindings
 documentation
Date: Fri, 25 Jul 2014 16:10:58 -0500
Message-ID: <20140725211058.32358.18883.stgit@tlendack-t1.amdoffice.net>
References: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0139.outbound.protection.outlook.com ([207.46.163.139]:47777
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760181AbaGYVLF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 17:11:05 -0400
In-Reply-To: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An earlier patch added support for the "dma-coherent" device property.
This patch adds this optional property to the amd-xgbe device bindings
documentation.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 Documentation/devicetree/bindings/net/amd-xgbe.txt |    1 +
 1 file changed, 1 insertion(+)

diff --git a/Documentation/devicetree/bindings/net/amd-xgbe.txt b/Documentation/devicetree/bindings/net/amd-xgbe.txt
index ea0c790..f6db1ba 100644
--- a/Documentation/devicetree/bindings/net/amd-xgbe.txt
+++ b/Documentation/devicetree/bindings/net/amd-xgbe.txt
@@ -18,6 +18,7 @@ Required properties:
 Optional properties:
 - mac-address: mac address to be assigned to the device. Can be overridden
   by UEFI.
+- dma-coherent: Present if dma operations are coherent
 
 Example:
 	xgbe@e0700000 {
