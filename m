From: Vitaly Bordug <vitb@kernel.crashing.org>
Subject: [PATCH 2/2] [POWERPC] Remove dummy network phy from MPC8313E-RDB
Date: Wed, 25 Jul 2007 21:43:20 +0400
Message-ID: <20070725174320.5818.91974.stgit@localhost.localdomain>
References: <20070725174312.5818.61155.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:38843 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760748AbXGYRnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jul 2007 13:43:31 -0400
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linuxppc-dev@ozlabs.org
In-Reply-To: <20070725174312.5818.61155.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cleaned up inexistent network phy from the target dts, added
necessary property to gianfar node there.

Signed-off-by: Vitaly Bordug <vitb@kernel.crashing.org>

---

 arch/powerpc/boot/dts/mpc8313erdb.dts |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/arch/powerpc/boot/dts/mpc8313erdb.dts b/arch/powerpc/boot/dts/mpc8313erdb.dts
index a1533cc..b602a8b 100644
--- a/arch/powerpc/boot/dts/mpc8313erdb.dts
+++ b/arch/powerpc/boot/dts/mpc8313erdb.dts
@@ -98,12 +98,6 @@
 			reg = <24520 20>;
 			#address-cells = <1>;
 			#size-cells = <0>;
-			phy1: ethernet-phy@1 {
-				interrupt-parent = < &ipic >;
-				interrupts = <13 8>;
-				reg = <1>;
-				device_type = "ethernet-phy";
-			};
 			phy4: ethernet-phy@4 {
 				interrupt-parent = < &ipic >;
 				interrupts = <14 8>;
@@ -120,7 +114,7 @@
 			local-mac-address = [ 00 00 00 00 00 00 ];
 			interrupts = <25 8 24 8 23 8>;
 			interrupt-parent = < &ipic >;
-			phy-handle = < &phy1 >;
+			fixed_speed = <1 1000>;
 		};
 
 		ethernet@25000 {

