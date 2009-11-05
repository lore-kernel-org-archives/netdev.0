From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH 1/6] Staging: Octeon: Fix compile error in drivers/staging/octeon/ethernet-mdio.c
Date: Thu, 05 Nov 2009 16:25:57 +0100
Message-ID: <20091105152702.035396736@linux-mips.org>
References: <20091105152555.227009519@linux-mips.org>
Cc: David Daney <ddaney@caviumnetworks.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	linux-mips@linux-mips.org, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-mips-bounce@linux-mips.org>
Content-Disposition: inline; filename=0002.patch
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

From: David Daney <ddaney@caviumnetworks.com>

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
Cc: Greg Kroah-Hartman <gregkh@suse.de>
Cc: devel@driverdev.osuosl.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mips@linux-mips.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

 drivers/staging/octeon/ethernet-mdio.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: upstream-linus/drivers/staging/octeon/ethernet-mdio.c
===================================================================
--- upstream-linus.orig/drivers/staging/octeon/ethernet-mdio.c
+++ upstream-linus/drivers/staging/octeon/ethernet-mdio.c
@@ -170,7 +170,7 @@ static u32 cvm_oct_get_link(struct net_d
 	return ret;
 }
 
-struct const ethtool_ops cvm_oct_ethtool_ops = {
+const struct ethtool_ops cvm_oct_ethtool_ops = {
 	.get_drvinfo = cvm_oct_get_drvinfo,
 	.get_settings = cvm_oct_get_settings,
 	.set_settings = cvm_oct_set_settings,
