From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [net-next PATCH 3/3] ARM: dts: dra72-evm-revc: fix non-working cpsw second ethernet
Date: Wed, 20 Jul 2016 20:26:14 +0530
Message-ID: <20160720145614.13132-4-mugunthanvnm@ti.com>
References: <20160720145614.13132-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
	Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160720145614.13132-1-mugunthanvnm-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Second ethernet of cpsw is not working, make it work by adding
impedance configuration.

Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
---
 arch/arm/boot/dts/dra72-evm-revc.dts | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/arm/boot/dts/dra72-evm-revc.dts b/arch/arm/boot/dts/dra72-evm-revc.dts
index f9cfd3b..4313de5 100644
--- a/arch/arm/boot/dts/dra72-evm-revc.dts
+++ b/arch/arm/boot/dts/dra72-evm-revc.dts
@@ -69,5 +69,7 @@
 		ti,rx-internal-delay = <DP83867_RGMIIDCTL_2_00_NS>;
 		ti,tx-internal-delay = <DP83867_RGMIIDCTL_1_NS>;
 		ti,fifo-depth = <DP83867_PHYCR_FIFO_DEPTH_8_B_NIB>;
+		ti,impedance-control = <0x1f>;
 	};
 };
+
-- 
2.9.2.368.g08bb350

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
