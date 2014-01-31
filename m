From: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next 1/2] dts: Add bindings for multicast hash bins and perfect filter entries
Date: Fri, 31 Jan 2014 14:15:55 -0600
Message-ID: <1391199356-27226-2-git-send-email-vbridgers2013@gmail.com>
References: <1391199356-27226-1-git-send-email-vbridgers2013@gmail.com>
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org,
	rayagond-AmucfkJibqKGw+nKnLezzg@public.gmane.org, vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1391199356-27226-1-git-send-email-vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This change adds bindings for the number of multicast hash bins and perfect
filter entries supported by the Synopsys EMAC. The Synopsys EMAC core is
configurable at device creation time, and can be configured for a different
number of multicast hash bins and a different number of perfect filter entries.
The device does not provide a way to query these parameters, therefore
parameters are required. The Altera Cyclone V SOC has support for 256
multicast hash bins and 128 perfect filter entries, and is different than
what's currently provided in the stmmac driver.

Signed-off-by: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 Documentation/devicetree/bindings/net/stmmac.txt |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/stmmac.txt b/Documentation/devicetree/bindings/net/stmmac.txt
index 9d92d42..dbf7498 100644
--- a/Documentation/devicetree/bindings/net/stmmac.txt
+++ b/Documentation/devicetree/bindings/net/stmmac.txt
@@ -34,6 +34,10 @@ Optional properties:
 	reset phandle is given
 - max-frame-size:	Maximum Transfer Unit (IEEE defined MTU), rather
 			than the maximum frame size.
+- snps,multicast-filter-bins:	Number of multicast filter hash bins
+				supported by this device instance
+- snps,perfect-filter-entries:	Number of perfect filter entries supported
+				by this device instance
 
 Examples:
 
@@ -46,4 +50,6 @@ Examples:
 		mac-address = [000000000000]; /* Filled in by U-Boot */
 		max-frame-size = <3800>;
 		phy-mode = "gmii";
+		snps,multicast-filter-bins = <256>;
+		snps,perfect-filter-entries = <128>;
 	};
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
