From: Wolfram Sang <wsa@the-dreams.de>
Subject: [PATCH 0/6] treewide: test clock rate to avoid division by 0
Date: Wed,  2 Mar 2016 23:33:31 +0100
Message-ID: <1456958018-7849-1-git-send-email-wsa@the-dreams.de>
Cc: linux-renesas-soc@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-ide@vger.kernel.org,
	linux-pwm@vger.kernel.org, linux-watchdog@vger.kernel.org,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-ide-owner@vger.kernel.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is the outcome of researching if the result of clk_get_rate() was directly
used as a divisor without checking if it is 0. Inspired by a Coverity report.

Wolfram Sang (6):
  ide: palm_bk3710: test clock rate to avoid division by 0
  net: ethernet: renesas: ravb_main: test clock rate to avoid division
    by 0
  pwm: pwm-img: test clock rate to avoid division by 0
  pwm: pwm-lpc18xx-sct: test clock rate to avoid division by 0
  watchdog: atlas7_wdt: test clock rate to avoid division by 0
  watchdog: tangox_wdt: test clock rate to avoid division by 0

 drivers/ide/palm_bk3710.c                | 2 ++
 drivers/net/ethernet/renesas/ravb_main.c | 3 +++
 drivers/pwm/pwm-img.c                    | 5 +++++
 drivers/pwm/pwm-lpc18xx-sct.c            | 2 ++
 drivers/watchdog/atlas7_wdt.c            | 5 +++++
 drivers/watchdog/tangox_wdt.c            | 2 ++
 6 files changed, 19 insertions(+)

-- 
2.7.0

