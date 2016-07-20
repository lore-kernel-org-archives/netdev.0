From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 0/3] add support for impedance control for TI dp83867
 phy and fix 2nd ethernet on dra72 rev C evm
Date: Wed, 20 Jul 2016 20:26:11 +0530
Message-ID: <20160720145614.13132-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Mugunthan V N <mugunthanvnm@ti.com>,
 Tony Lindgren <tony@atomide.com>, Sekhar Nori <nsekhar@ti.com>,
 Russell King <linux@armlinux.org.uk>, linux-kernel@vger.kernel.org,
 Rob Herring <robh+dt@kernel.org>, linux-omap@vger.kernel.org,
 "David S . Miller" <davem@davemloft.net>, linux-arm-kernel@lists.infradead.org
To: <netdev@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Add support for configurable impedance control for TI dp83867
phy via devicetree. More documentation in [1]
CPSW second ethernet is not working, fix it by enabling
impedance configuration on the phy.

Public Datasheet - http://www.ti.com/lit/ds/symlink/dp83867ir.pdf

Mugunthan V N (3):
  net: phy: dp83867: Add documentation for optional impedance control
  net: phy: dp83867: add support for MAC impedance configuration
  ARM: dts: dra72-evm-revc: fix non-working cpsw second ethernet

 .../devicetree/bindings/net/ti,dp83867.txt         |  7 +++++++
 arch/arm/boot/dts/dra72-evm-revc.dts               |  2 ++
 drivers/net/phy/dp83867.c                          | 22 ++++++++++++++++++++++
 3 files changed, 31 insertions(+)

-- 
2.9.2.368.g08bb350
