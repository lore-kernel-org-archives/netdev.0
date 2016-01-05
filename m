From: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v5 net-next 0/3] Add new capability and macb DT variant
Date: Tue,  5 Jan 2016 14:39:15 +0100
Message-ID: <1452001158-20585-1-git-send-email-narmstrong@baylibre.com>
References: <1451900573-22657-1-git-send-email-narmstrong@baylibre.com>
Cc: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, boris.brezillon-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org,
	alexandre.belloni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, joshc-acOepvfBmUk@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1451900573-22657-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The first patch introduces a new capability bit to disable usage of the
USRIO register on platform not implementing it thus avoiding some external
imprecise aborts on ARM based platforms.
The two last patchs adds a new macb variant compatible name using the
capability, the NP4 SoC uses this particular hardware configuration.

v1: http://lkml.kernel.org/r/1449485914-12883-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
v2: http://lkml.kernel.org/r/1449582726-6148-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
v3: http://lkml.kernel.org/r/1451898103-21868-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
v4: http://lkml.kernel.org/r/1451900573-22657-1-git-send-email-narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org
v5: switch SoC name to non-generic NP4 name

Neil Armstrong (3):
  net: ethernet: cadence-macb: Add disabled usrio caps
  net: macb: Add NP4 macb config using USRIO_DISABLED
  dt-bindings: net: macb: Add NP4 macb variant

 Documentation/devicetree/bindings/net/macb.txt |  1 +
 drivers/net/ethernet/cadence/macb.c            | 33 ++++++++++++++++----------
 drivers/net/ethernet/cadence/macb.h            |  1 +
 3 files changed, 23 insertions(+), 12 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
