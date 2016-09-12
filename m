From: Javier Martinez Canillas <javier@osg.samsung.com>
Subject: [PATCH 00/15] drivers: net: use IS_ENABLED() instead of checking for built-in or module
Date: Mon, 12 Sep 2016 10:03:31 -0400
Message-ID: <1473689026-6983-1-git-send-email-javier@osg.samsung.com>
Cc: Javier Martinez Canillas <javier@osg.samsung.com>,
        Arnd Bergmann <arnd@arndb.de>,
        Sony Chacko <sony.chacko@qlogic.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
        Florian Westphal <fw@strlen.de>,
        Bert Kenward <bkenward@solarflare.com>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Edward Cree <ecree@solarflare.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Marcin Wojtas <mw@semihalf.com>,
        Antonio Quartulli <a@unstable.cc>,
        intel-wired-lan@lists.osuosl.org,
        Florian Fainelli <f.fainelli@gmail.com>,
        Felipe Balbi <felipe.balbi@linux.intel.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Dept-HSGLinuxNICDev@qlogic.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Mugunthan V N <mu
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello David,

This trivial series is similar to [0] for net/ that you already merged, but
for drivers/net. The patches replaces the open coding to check for a Kconfig
symbol being built-in or module, with IS_ENABLED() macro that does the same.

Using the macro makes the code more readable by helping abstract away some
of the Kconfig built-in and module enable details.

[0]: https://lkml.org/lkml/2016/9/9/323

Best regards,
Javier


Javier Martinez Canillas (15):
  3c59x: use IS_ENABLED() instead of checking for built-in or module
  starfire: use IS_ENABLED() instead of checking for built-in or module
  ethernet: amd: use IS_ENABLED() instead of checking for built-in or
    module
  bnx2: use IS_ENABLED() instead of checking for built-in or module
  sundance: use IS_ENABLED() instead of checking for built-in or module
  net/fsl_pq_mdio: use IS_ENABLED() instead of checking for built-in or
    module
  i825xx: use IS_ENABLED() instead of checking for built-in or module
  ixgbe: use IS_ENABLED() instead of checking for built-in or module
  net: mvneta: use IS_ENABLED() instead of checking for built-in or
    module
  natsemi: use IS_ENABLED() instead of checking for built-in or module
  sfc: use IS_ENABLED() instead of checking for built-in or module
  sis900: use IS_ENABLED() instead of checking for built-in or module
  stmmac: use IS_ENABLED() instead of checking for built-in or module
  hamradio: use IS_ENABLED() instead of checking for built-in or module
  iwlegacy: use IS_ENABLED() instead of checking for built-in or module

 drivers/net/ethernet/3com/3c59x.c            | 2 +-
 drivers/net/ethernet/adaptec/starfire.c      | 2 +-
 drivers/net/ethernet/amd/7990.c              | 6 +++---
 drivers/net/ethernet/amd/amd8111e.c          | 2 +-
 drivers/net/ethernet/broadcom/bnx2.c         | 2 +-
 drivers/net/ethernet/dlink/sundance.c        | 2 +-
 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 8 ++++----
 drivers/net/ethernet/i825xx/82596.c          | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe.h     | 4 ++--
 drivers/net/ethernet/marvell/mvneta_bm.h     | 2 +-
 drivers/net/ethernet/natsemi/ns83820.c       | 2 +-
 drivers/net/ethernet/sfc/falcon_boards.c     | 4 ++--
 drivers/net/ethernet/sis/sis900.c            | 4 ++--
 drivers/net/ethernet/sis/sis900.h            | 2 +-
 drivers/net/ethernet/stmicro/stmmac/common.h | 2 +-
 drivers/net/hamradio/bpqether.c              | 2 +-
 drivers/net/wireless/intel/iwlegacy/common.h | 4 ++--
 17 files changed, 27 insertions(+), 27 deletions(-)

-- 
2.7.4
