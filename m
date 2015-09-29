From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH 0/5] net: m68k: Allow modular build
Date: Tue, 29 Sep 2015 10:24:01 +0200
Message-ID: <1443515046-13968-1-git-send-email-geert@linux-m68k.org>
Cc: Finn Thain <fthain@telegraphics.com.au>,
	Joshua Thompson <funaho@jurai.org>,
	Philip Blundell <philb@gnu.org>, netdev@vger.kernel.org,
	linux-m68k@lists.linux-m68k.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi David, Paul,

This patch series makes the remaining m68k Ethernet drivers modular.
It's an alternative to the last 3 patches of Paul Gortmaker's series
"[PATCH net-next 0/6] make non-modular code explicitly non-modular".

Note that "[PATCH 5/5] net: macmace: Allow modular build" depends on
"[PATCH 4/5] m68k/mac: Export Peripheral System Controller (PSC) base
address to modules". Feel free to take the dependency through the netdev
tree to avoid modular build breakage.

This was compile-tested only (mac_defconfig + allmodconfig) due to lack
of hardware.

Thanks!

Geert Uytterhoeven (5):
  net: mac8390: Allow modular build
  net: 7990: Export lance_poll() to modules
  net: hplance: Allow modular build
  m68k/mac: Export Peripheral System Controller (PSC) base address to
    modules
  net: macmace: Allow modular build

 arch/m68k/mac/psc.c                 |  1 +
 drivers/net/ethernet/8390/Kconfig   |  2 +-
 drivers/net/ethernet/8390/mac8390.c | 32 ++++++++++----------------------
 drivers/net/ethernet/amd/7990.c     |  1 +
 drivers/net/ethernet/amd/Kconfig    |  2 +-
 drivers/net/ethernet/apple/Kconfig  |  2 +-
 6 files changed, 15 insertions(+), 25 deletions(-)

-- 
1.9.1

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
