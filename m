From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: [GIT PULL] net/at91: at91_ether fixes for 3.4-rc
Date: Thu, 26 Apr 2012 11:14:56 +0200
Message-ID: <4F991210.8060409@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Victor <avictor.za@gmail.com>,
 Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>,
 Linux Kernel list <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi David,

Can you please pull those fixes for 3.4-rc? The ARM/AT91 part
of modifications is pretty small and bounded to a single SoC so
it will not mess with arm-soc git tree.

Tell me if you need other information on this signed tag...

The following changes since commit 66f75a5d028beaf67c931435fdc3e7823125730c:

  Linux 3.4-rc4 (2012-04-21 14:47:52 -0700)

are available in the git repository at:

  git://github.com/at91linux/linux-at91.git tags/at91-3.4-net-fixes

for you to fetch changes up to cfc991548b5b73c8038f41877da1cd0104945cf5:

  net/at91_ether: use gpio_to_irq for phy IRQ line (2012-04-26 10:22:40 +0200)

----------------------------------------------------------------
Both fixes are about at91_ether.c driver: It is only used in a single
Atmel AT91 SoC: AT91RM9200.
The removal of fixed mapping is a long standing refinement which will
convert this driver to a more typical resources management.
The gpio fix is needed now that we have moved AT91 to irqdomains.

----------------------------------------------------------------
Andrew Victor (1):
      AT91: Remove fixed mapping for AT91RM9200 ethernet

Nicolas Ferre (1):
      net/at91_ether: use gpio_to_irq for phy IRQ line

 arch/arm/mach-at91/at91rm9200.c            |   10 --
 arch/arm/mach-at91/at91rm9200_devices.c    |    4 +-
 arch/arm/mach-at91/include/mach/hardware.h |    1 -
 drivers/net/ethernet/cadence/at91_ether.c  |  535 ++++++++++++++++++++++++++++++++++++++++++++-------------------------------------
 drivers/net/ethernet/cadence/at91_ether.h  |    1 +
 5 files changed, 291 insertions(+), 260 deletions(-)

Best regards,
-- 
Nicolas Ferre
