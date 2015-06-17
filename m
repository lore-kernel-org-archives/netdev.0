From: Antonio Borneo <borneo.antonio@gmail.com>
Subject: [PATCH 0/2] replace USE_OF in drivers
Date: Wed, 17 Jun 2015 19:42:29 +0800
Message-ID: <1434541351-9699-1-git-send-email-borneo.antonio@gmail.com>
Cc: Antonio Borneo <borneo.antonio@gmail.com>
To: Daniel Lezcano <daniel.lezcano@linaro.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kconfig option USE_OF is used as intermediate option by few
arch's (ARM, MIPS, Xtensa); in all these cases USE_OF implies
setting option OF and other OF_???.

Outside arch folder, USE_OF is used only in two places.
In both places, USE_OF can be replaced by OF or OF_???.
This change reduces the scope of USE_OF and makes the drivers
(actually only the Via network ones) available to other arch's
that don't use USE_OF.

The two patches of this series can be applied independently and
can be taken separately in the respective tree.

Antonio Borneo (2):
  clocksource: Kconfig: replace USE_OF with OF
  net: via/Kconfig: replace USE_OF with OF_???

 drivers/clocksource/Kconfig      | 2 +-
 drivers/net/ethernet/via/Kconfig | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

-- 
2.4.3
