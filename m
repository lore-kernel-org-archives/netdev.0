From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 02/10] ARM: mvebu: enable SRAM support in
 mvebu_v7_defconfig
Date: Tue, 12 Jan 2016 20:10:26 +0100
Message-ID: <1452625834-22166-3-git-send-email-gregory.clement@free-electrons.com>
References: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Boris BREZILLON <boris.brezillon@free-electrons.com>,
 Simon Guinot <simon.guinot@sequanux.org>, Nadav Haklai <nadavh@marvell.com>,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Maxime Ripard <maxime.ripard@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1452625834-22166-1-git-send-email-gregory.clement@free-electrons.com>
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

From: Marcin Wojtas <mw@semihalf.com>

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
---
 arch/arm/configs/mvebu_v7_defconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/configs/mvebu_v7_defconfig b/arch/arm/configs/mvebu_v7_defconfig
index c6729bf0a8dd..fe57e20ba200 100644
--- a/arch/arm/configs/mvebu_v7_defconfig
+++ b/arch/arm/configs/mvebu_v7_defconfig
@@ -58,6 +58,7 @@ CONFIG_MTD_M25P80=y
 CONFIG_MTD_NAND=y
 CONFIG_MTD_NAND_PXA3xx=y
 CONFIG_MTD_SPI_NOR=y
+CONFIG_SRAM=y
 CONFIG_EEPROM_AT24=y
 CONFIG_BLK_DEV_SD=y
 CONFIG_ATA=y
-- 
2.5.0
