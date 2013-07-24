From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH v5 3/3] ARM: shmobile: lager: enable nfsroot in DTS
Date: Wed, 24 Jul 2013 17:56:09 +0900
Message-ID: <1374656169-9241-4-git-send-email-horms+renesas@verge.net.au>
References: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59296 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012Ab3GXI4P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jul 2013 04:56:15 -0400
In-Reply-To: <1374656169-9241-1-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that Ether support has been added to the lager board
it is possible to use nfsroot. This configuration is
in line with that of other shmobile boards.

Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Signed-off-by: Simon Horman <horms+renesas@verge.net.au>

---

This patch has a run-time dependency on "ARM: shmobile: lager: enable Ether"

v2
* Split out as a new patch from "ARM: shmobile: lager: enable Ether"
---
 arch/arm/boot/dts/r8a7790-lager.dts | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/boot/dts/r8a7790-lager.dts b/arch/arm/boot/dts/r8a7790-lager.dts
index 09a84fc..b2f61f0 100644
--- a/arch/arm/boot/dts/r8a7790-lager.dts
+++ b/arch/arm/boot/dts/r8a7790-lager.dts
@@ -16,7 +16,7 @@
 	compatible = "renesas,lager", "renesas,r8a7790";
 
 	chosen {
-		bootargs = "console=ttySC6,115200 ignore_loglevel";
+		bootargs = "console=ttySC6,115200 ignore_loglevel root=/dev/nfs ip=dhcp nfsroot=,rsize=4096,wsize=4096 rw";
 	};
 
 	memory@40000000 {
-- 
1.8.2.1
