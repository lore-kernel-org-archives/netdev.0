From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 3/7] ARM: dove: remove legacy mv643xx_eth setup
Date: Mon,  6 May 2013 17:33:36 +0200
Message-ID: <1367854420-8006-4-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
 <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>, Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>,
 Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>,
 Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
 Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>,
 Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>,
 devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>,
 Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>, Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Willy Tarreau <w@1wt.eu>,
 David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1367854420-8006-1-git-send-email-sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

With DT support for mv643xx_eth we do not need legacy platform_data
based setup for DT enabled boards.

Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
Cc: Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Cc: Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>
Cc: Rob Landley <rob-VoJi6FS/r0vR7s880joybQ@public.gmane.org>
Cc: Lennert Buytenhek <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: Florian Fainelli <florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Cc: Arnaud Patard <arnaud.patard-dQbF7i+pzddAfugRpC6u6w@public.gmane.org>
Cc: Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
Cc: Jason Cooper <jason-NLaQJdtUoK4Be96aLqz0jA@public.gmane.org>
Cc: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Cc: Jean-Francois Moine <moinejf-GANU6spQydw@public.gmane.org>
Cc: Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Cc: Simon Guinot <simon.guinot-jKBdWWKqtFpg9hUCZPvPmw@public.gmane.org>
Cc: Jamie Lentin <jm-Pj/HzkgeCk7QXOPxS62xeg@public.gmane.org>
Cc: Michael Walle <michael-QKn5cuLxLXY@public.gmane.org>
Cc: Eric Hutter <hutter.eric-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Joshua Coombs <josh.coombs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Willy Tarreau <w@1wt.eu>
Cc: Simon Baatz <gmbnomis-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Alan M Butler <alanbutty12-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Nigel Roberts <nigel-BZPLJ9//LnDby3iVrkZq2A@public.gmane.org>
Cc: Valentin Longchamp <valentin.longchamp-SkAbAL50j+5BDgjK7y7TUQ@public.gmane.org>
Cc: Stefan Peter <s.peter-R0yVo0h44Ow@public.gmane.org>
Cc: Arnaud Ebalard <arno-LkuqDEemtHBg9hUCZPvPmw@public.gmane.org>
Cc: Nobuhiro Iwamatsu <iwamatsu-+mkmVskJBflAfugRpC6u6w@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Cc: linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 arch/arm/mach-dove/board-dt.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/arch/arm/mach-dove/board-dt.c b/arch/arm/mach-dove/board-dt.c
index fbde1dd..3c0963d 100644
--- a/arch/arm/mach-dove/board-dt.c
+++ b/arch/arm/mach-dove/board-dt.c
@@ -34,10 +34,6 @@ static void __init dove_legacy_clk_init(void)
 	clkspec.np = np;
 	clkspec.args_count = 1;
 
-	clkspec.args[0] = CLOCK_GATING_BIT_GBE;
-	orion_clkdev_add(NULL, "mv643xx_eth_port.0",
-			 of_clk_get_from_provider(&clkspec));
-
 	clkspec.args[0] = CLOCK_GATING_BIT_PCIE0;
 	orion_clkdev_add("0", "pcie",
 			 of_clk_get_from_provider(&clkspec));
@@ -70,7 +66,6 @@ static void __init dove_dt_init(void)
 	dove_of_clk_init();
 
 	/* Internal devices not ported to DT yet */
-	dove_ge00_init(&dove_dt_ge00_data);
 	dove_pcie_init(1, 1);
 
 	of_platform_populate(NULL, of_default_bus_match_table, NULL, NULL);
-- 
1.7.2.5
