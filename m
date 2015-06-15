From: Simon Guinot <simon.guinot@sequanux.org>
Subject: [PATCH 0/2] Fix Ethernet jumbo frames support for Armada 370
Date: Mon, 15 Jun 2015 16:27:21 +0200
Message-ID: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
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

Hello,

This patch series fixes the Ethernet jumbo frames support for Armada 370
SoCs. Unlike Armada XP, the Ethernet controller in Armada 370 SoCs don't
support TCP/IP checksumming with frames largest than 1600 Bytes.

This patches should be applied to the -stable kernels 3.8 and onwards.

Regards,

Simon

Simon Guinot (2):
  net: mvneta: introduce tx_csum_limit property
  ARM: mvebu: disable IP checksum with jumbo frames for Armada 370

 .../bindings/net/marvell-armada-370-neta.txt       |  3 +++
 arch/arm/boot/dts/armada-370.dtsi                  |  8 +++++++
 drivers/net/ethernet/marvell/mvneta.c              | 25 +++++++++++++++++++++-
 3 files changed, 35 insertions(+), 1 deletion(-)

--
Cc: <stable@vger.kernel.org>
-- 
2.1.4
