From: Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
Subject: [PATCH 0/2] net: smc91x: add DT flags for legacy platforms
Date: Wed, 11 Dec 2013 04:21:43 -0600
Message-ID: <1386757305-12545-1-git-send-email-nm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-doc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	=?UTF-8?q?Beno=C3=AEt=20Cousson?= <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, Nishanth Menon <nm-l0cyMroinI0@public.gmane.org>
To: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

SMC91x driver has been converted to device tree, however users of
older lan91c94 based platform need description provided previously by
platform_data. Without this, ethernet fails to function on these platforms.

For example, on SDP2430:
Before: http://pastebin.mozilla.org/3753793
After: http://pastebin.mozilla.org/3753792

Nishanth Menon (2):
  net: smc91x: Read hardware behavior flags from device tree
  ARM: dts: omap2430-sdp: add flags for ethernet functionality

 Documentation/devicetree/bindings/net/smsc91x.txt |   45 +++++++++
 arch/arm/boot/dts/omap2430-sdp.dts                |    5 +
 drivers/net/ethernet/smsc/smc91x.c                |  106 ++++++++++++++++++++-
 3 files changed, 155 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/smsc91x.txt

Regards,
Nishanth Menon
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
