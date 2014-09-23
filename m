From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: [PATCH v4 0/9] ARM: Berlin: Ethernet support
Date: Tue, 23 Sep 2014 14:15:27 +0200
Message-ID: <1411474536-22626-1-git-send-email-antoine.tenart@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, zmxu@marvell.com,
 devicetree@vger.kernel.org, netdev@vger.kernel.org,
 Antoine Tenart <antoine.tenart@free-electrons.com>,
 linux-kernel@vger.kernel.org, alexandre.belloni@free-electrons.com,
 jszhang@marvell.com, linux-arm-kernel@lists.infradead.org
To: sebastian.hesselbarth@gmail.com
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

Hi all,

This series introduce support for the Ethernet controller on Berlin SoCs,
using the existing pxa168 Ethernet driver. In order to do this, DT
support is added to the driver alongside some other modifications and
fixes.

This has been tested on a Berlin BG2Q DMP board.

Changes since v3:
	- moved the addition of pxa168_eth_get_mac_address() to the patch
	  using it first

Changes since v2:
        - reworked how the MAC address is configured
        - made the clock anonymous

Changes since v1:
        - removed custom Berlin Ethernet driver
        - used the pxa168 Ethernet driver instead
        - made modifications to the pxa168 driver (DT support, fixes)

Antoine Tenart (9):
  net: pxa168_eth: clean up
  net: pxa168_eth: add device tree support
  Documentation: bindings: net: add the Marvell PXA168 Ethernet
    controller
  net: pxa168_eth: fix Ethernet flow control status
  net: pxa168_eth: set the mac address on the Ethernet controller
  net: pxa168_eth: rework the MAC address setup
  net: pxa168_eth: allow Berlin SoCs to use the pxa168_eth driver
  ARM: dts: berlin: add the Ethernet node
  ARM: dts: berlin: enable the Ethernet port on the BG2Q DMP

 .../devicetree/bindings/net/marvell-pxa168.txt     |  21 ++
 arch/arm/boot/dts/berlin2q-marvell-dmp.dts         |   4 +
 arch/arm/boot/dts/berlin2q.dtsi                    |  10 +
 drivers/net/ethernet/marvell/Kconfig               |   2 +-
 drivers/net/ethernet/marvell/pxa168_eth.c          | 216 +++++++++++++--------
 5 files changed, 174 insertions(+), 79 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/marvell-pxa168.txt

-- 
1.9.1
