From: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Subject: [PATCH 0/4] net: hix5hd2_gmac: add tx sg feature and reset/clock control signals
Date: Thu, 11 Aug 2016 17:01:51 +0800
Message-ID: <1470906115-155569-1-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <benjamin.chenhao-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>,
	<howell.yang-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-clk-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
To: <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	<mturquette-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>, <sboyd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	<linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>, <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	<yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The "hix5hd2" is SoC name, add the generic ethernet driver name.
The "hisi-gemac-v1" is the basic version and "hisi-gemac-v2" adds
the SG/TXCSUM/TSO/UFO features.
This patch set only adds the SG(scatter-gather) driver for transmitting,
the drivers of other features will be submitted later.

Add the MAC reset control signals and clock signals.
As a result, the hix5hd2 ethernet clock can be abstracted as
gate clock instead of self defined complex clock.

Dongpo Li (2):
  clk: hix5hd2: change ethernet clock type
  ARM: dts: hix5hd2: add gmac clock and reset property

Li Dongpo (2):
  net: hix5hd2_gmac: add tx scatter-gather feature
  net: hix5hd2_gmac: add reset control and clock signals

 .../bindings/net/hisilicon-hix5hd2-gmac.txt        |  25 +-
 arch/arm/boot/dts/hisi-x5hd2-dkb.dts               |   2 +
 arch/arm/boot/dts/hisi-x5hd2.dtsi                  |  15 +-
 drivers/clk/hisilicon/clk-hix5hd2.c                |  72 +----
 drivers/net/ethernet/hisilicon/hix5hd2_gmac.c      | 353 +++++++++++++++++++--
 include/dt-bindings/clock/hix5hd2-clock.h          |   6 +-
 6 files changed, 381 insertions(+), 92 deletions(-)

-- 
2.8.2

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
