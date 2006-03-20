From: Martin Michlmayr <tbm@cyrius.com>
Subject: [PATCH 4/12] [NET] Improve description of MV643XX_ETH
Date: Mon, 20 Mar 2006 04:39:44 +0000
Message-ID: <20060320043944.GD20416@deprecation.cyrius.com>
References: <20060320043802.GA20389@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751505AbWCTEkN@vger.kernel.org>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20060320043802.GA20389@deprecation.cyrius.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Slightly improve the wording of the description of MV643XX_ETH
in Kconfig.  This difference was found between the mainline and
linux-mips kernel trees.

Signed-off-by: Martin Michlmayr <tbm@cyrius.com>


--- linux-2.6/drivers/net/Kconfig	2006-03-13 18:55:59.000000000 +0000
+++ mips.git/drivers/net/Kconfig	2006-03-13 18:43:52.000000000 +0000
@@ -2197,8 +2213,8 @@
 	depends on MOMENCO_OCELOT_C || MOMENCO_JAGUAR_ATX || MV64360 || MOMENCO_OCELOT_3 || PPC_MULTIPLATFORM
 	help
 	  This driver supports the gigabit Ethernet on the Marvell MV643XX
-	  chipset which is used in the Momenco Ocelot C and Jaguar ATX and
-	  Pegasos II, amongst other PPC and MIPS boards.
+	  chipset which is used in the Momenco Ocelot C Ocelot, Jaguar ATX
+	  and Pegasos II, amongst other PPC and MIPS boards.
 
 config MV643XX_ETH_0
 	bool "MV-643XX Port 0"

-- 
Martin Michlmayr
http://www.cyrius.com/
