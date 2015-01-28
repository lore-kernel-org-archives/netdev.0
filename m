From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 0/4] net: driver fixes from arm randconfig builds
Date: Wed, 28 Jan 2015 15:15:00 +0100
Message-ID: <1422454504-439085-1-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>, linux-pcmcia@lists.infradead.org,
 jeffrey.t.kirsher@intel.com, kas@fi.muni.cz, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-pcmcia/>
List-Post: <mailto:linux-pcmcia@lists.infradead.org>
List-Help: <mailto:linux-pcmcia-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-pcmcia>,
 <mailto:linux-pcmcia-request@lists.infradead.org?subject=subscribe>
Sender: "linux-pcmcia" <linux-pcmcia-bounces@lists.infradead.org>
Errors-To: linux-pcmcia-bounces+glkpd-linux-pcmcia=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

These four patches are fallout from test builds on ARM. I have a
few more of them in my backlog but have not yet confirmed them
to still be valid.

The first three patches are about incomplete dependencies on
old drivers. One could backport them to the beginning of time
in theory, but there is little value since nobody would run into
these problems.

The final patch is one I had submitted before together with the
respective pcmcia patch but forgot to follow up on that. It's
still a valid but relatively theoretical bug, because the previous
behavior of the driver was just as broken as what we have in
mainline.

Please apply,

	Arnd

Arnd Bergmann (4):
  net: cs89x0: always build platform code if !HAS_IOPORT_MAP
  net: wan: add missing virt_to_bus dependencies
  net: lance,ni64: don't build for ARM
  net: am2150: fix nmclan_cs.c shared interrupt handling

 drivers/net/ethernet/amd/Kconfig     | 4 ++--
 drivers/net/ethernet/amd/nmclan_cs.c | 2 ++
 drivers/net/ethernet/cirrus/Kconfig  | 3 ++-
 drivers/net/wan/Kconfig              | 6 +++---
 4 files changed, 9 insertions(+), 6 deletions(-)

-- 
2.1.0.rc2
