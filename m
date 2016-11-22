From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 0/4] Extend mvneta to support Armada 3700 (ARM 64)
Date: Tue, 22 Nov 2016 17:48:40 +0100
Message-ID: <20161122164844.19566-1-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Andrew Lunn <andrew@lunn.ch>, Jason Cooper <jason@lakedaemon.net>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org
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

Hi,

This series enable the use of mvneta driver on the Armada 3700
SoCs. Armada 3700 is a new ARMv8 SoC from Marvell using same network
controller as older Armada 370/38x/XP.

Besides the changes needed to be used on 64-bits architecture done in
the 1st patch, there are also few difference related to the Armada
3700 SoC. The main one being the used of shared interrupt instead of
the private ones. It has been addressed in the 3rd patch.

Not all the feature supported on the older Soc have been ported yet
for this new SoC.

Gregory CLEMENT (2):
  net: mvneta: Only disable mvneta_bm for 64-bits
  ARM64: dts: marvell: Add network support for Armada 3700

Marcin Wojtas (2):
  net: mvneta: Convert to be 64 bits compatible
  net: mvneta: Add network support for Armada 3700 SoC

 .../bindings/net/marvell-armada-370-neta.txt       |   7 +-
 arch/arm64/boot/dts/marvell/armada-3720-db.dts     |  23 ++
 arch/arm64/boot/dts/marvell/armada-37xx.dtsi       |  23 ++
 drivers/net/ethernet/marvell/Kconfig               |  10 +-
 drivers/net/ethernet/marvell/mvneta.c              | 364 ++++++++++++++++-----
 5 files changed, 333 insertions(+), 94 deletions(-)

-- 
2.10.2
