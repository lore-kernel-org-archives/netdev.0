From: Sebastian Hesselbarth <sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/7] mv643xx_eth: device tree bindings
Date: Mon,  6 May 2013 17:33:33 +0200
Message-ID: <1367854420-8006-1-git-send-email-sebastian.hesselbarth@gmail.com>
References: <1365071235-11611-1-git-send-email-florian@openwrt.org>
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
In-Reply-To: <1365071235-11611-1-git-send-email-florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
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

This patch set picks up work by Florian Fainelli bringing full DT
support to mv643xx_eth and Marvell SoCs using it.

The current patch set drops Florian's device tree conversions for
Kirkwood, Dove, and Orion5x in favour of split patches for board
files and board descriptor files.

Device tree conversion for Dove and Kirkwood is added. Dove has
been fully tested, while Kirkwood is compile-tested only.

Florian Fainelli (2):
  net: mv643xx_eth: add Device Tree bindings
  net: mv643xx_eth: update Device Tree bindings documentation

Sebastian Hesselbarth (5):
  ARM: dove: remove legacy mv643xx_eth setup
  ARM: dove: add gigabit ethernet and mvmdio device tree nodes
  ARM: kirkwood: remove legacy mv643xx_eth board setup
  ARM: kirkwood: add gigabit ethernet and mvmdio device tree nodes
  ARM: kirkwood: remove legacy clk alias for mv643xx_eth

 Documentation/devicetree/bindings/marvell.txt      |   22 ++++-
 arch/arm/boot/dts/dove-cubox.dts                   |    8 ++
 arch/arm/boot/dts/dove.dtsi                        |   35 +++++++
 arch/arm/boot/dts/kirkwood-cloudbox.dts            |   15 +++
 arch/arm/boot/dts/kirkwood-dnskw.dtsi              |   15 +++
 arch/arm/boot/dts/kirkwood-dockstar.dts            |   15 +++
 arch/arm/boot/dts/kirkwood-dreamplug.dts           |   26 +++++
 arch/arm/boot/dts/kirkwood-goflexnet.dts           |   15 +++
 .../arm/boot/dts/kirkwood-guruplug-server-plus.dts |   26 +++++
 arch/arm/boot/dts/kirkwood-ib62x0.dts              |   15 +++
 arch/arm/boot/dts/kirkwood-iconnect.dts            |   15 +++
 arch/arm/boot/dts/kirkwood-iomega_ix2_200.dts      |   22 ++++
 arch/arm/boot/dts/kirkwood-is2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-km_kirkwood.dts         |   15 +++
 arch/arm/boot/dts/kirkwood-lsxl.dtsi               |   26 +++++
 arch/arm/boot/dts/kirkwood-mplcec4.dts             |   25 +++++
 .../boot/dts/kirkwood-netgear_readynas_duo_v2.dts  |   15 +++
 arch/arm/boot/dts/kirkwood-ns2-common.dtsi         |   15 +++
 arch/arm/boot/dts/kirkwood-ns2.dts                 |    2 +
 arch/arm/boot/dts/kirkwood-ns2lite.dts             |    2 +
 arch/arm/boot/dts/kirkwood-ns2max.dts              |    2 +
 arch/arm/boot/dts/kirkwood-ns2mini.dts             |    2 +
 arch/arm/boot/dts/kirkwood-openblocks_a6.dts       |   15 +++
 arch/arm/boot/dts/kirkwood-topkick.dts             |   15 +++
 arch/arm/boot/dts/kirkwood-ts219-6281.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219-6282.dts          |    4 +-
 arch/arm/boot/dts/kirkwood-ts219.dtsi              |   15 +++
 arch/arm/boot/dts/kirkwood.dtsi                    |   52 ++++++++++
 arch/arm/mach-dove/board-dt.c                      |    5 -
 arch/arm/mach-kirkwood/board-dnskw.c               |    7 --
 arch/arm/mach-kirkwood/board-dockstar.c            |    9 --
 arch/arm/mach-kirkwood/board-dreamplug.c           |   14 ---
 arch/arm/mach-kirkwood/board-dt.c                  |   16 ---
 arch/arm/mach-kirkwood/board-goflexnet.c           |    9 --
 arch/arm/mach-kirkwood/board-guruplug.c            |   14 ---
 arch/arm/mach-kirkwood/board-ib62x0.c              |    9 --
 arch/arm/mach-kirkwood/board-iconnect.c            |    6 -
 arch/arm/mach-kirkwood/board-iomega_ix2_200.c      |   16 ---
 arch/arm/mach-kirkwood/board-km_kirkwood.c         |    7 --
 arch/arm/mach-kirkwood/board-lsxl.c                |   12 --
 arch/arm/mach-kirkwood/board-mplcec4.c             |   11 --
 arch/arm/mach-kirkwood/board-ns2.c                 |   13 ---
 arch/arm/mach-kirkwood/board-openblocks_a6.c       |    9 --
 arch/arm/mach-kirkwood/board-readynas.c            |    6 -
 arch/arm/mach-kirkwood/board-ts219.c               |   13 ---
 arch/arm/mach-kirkwood/board-usi_topkick.c         |    9 --
 drivers/net/ethernet/marvell/mv643xx_eth.c         |  108 +++++++++++++++++++-
 include/linux/mv643xx_eth.h                        |    3 +
 48 files changed, 544 insertions(+), 192 deletions(-)
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
-- 
1.7.2.5
