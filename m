From: Giuseppe CAVALLARO <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
Subject: Re: net: stmmac glue layer for Amlogic Meson SoCs
Date: Tue, 23 Sep 2014 08:16:18 +0200
Message-ID: <54211032.6010009@st.com>
References: <1411219757-9201-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
	Jerry Cao <jerry.cao-LpR1jeaWuhtBDgjK7y7TUQ@public.gmane.org>,
	Victor Wan <victor.wan-LpR1jeaWuhtBDgjK7y7TUQ@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Beniamino Galvani <b.galvani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1411219757-9201-1-git-send-email-b.galvani-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9/20/2014 3:29 PM, Beniamino Galvani wrote:
> Hi,
>
> the Ethernet controller available in Amlogic Meson6 and Meson8 SoCs is
> a Synopsys DesignWare MAC IP core, already supported by the stmmac
> driver.
>
> These patches add a glue layer to the driver for the platform-specific
> settings required by the Amlogic variant.
>
> This has been tested on a Amlogic S802 device with the initial Meson
> support submitted by Carlo Caione [1].

patches look fine just a warning with checkpatch as shown below then

Acked-by: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>


[cavagiu@lxmcdt5 net.git]$ git-format-patch -2
0001-net-stmmac-add-Amlogic-Meson-glue-layer.patch
0002-net-stmmac-meson-document-device-tree-bindings.patch
[cavagiu@lxmcdt5 net.git]$ !./
./scripts/checkpatch.pl 000*
WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
#57:
new file mode 100644

WARNING: DT compatible string vendor "amlogic" appears un-documented -- 
check ./Documentation/devicetree/bindings/vendor-prefixes.txt
#152: FILE: drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c:34:
+	{ .compatible = "amlogic,meson6-dwmac", .data = &meson6_dwmac_data},

total: 0 errors, 2 warnings, 0 checks, 108 lines checked

0001-net-stmmac-add-Amlogic-Meson-glue-layer.patch has style problems, 
please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.
WARNING: added, moved or deleted file(s), does MAINTAINERS need updating?
#17:
new file mode 100644

total: 0 errors, 1 warnings, 25 lines checked

0002-net-stmmac-meson-document-device-tree-bindings.patch has style 
problems, please review.

If any of these errors are false positives, please report
them to the maintainer, see CHECKPATCH in MAINTAINERS.

>
> [1] http://lwn.net/Articles/612000/
>
> Beniamino Galvani (2):
>    net: stmmac: add Amlogic Meson glue layer
>    net: stmmac: meson: document device tree bindings
>
>   .../devicetree/bindings/net/meson-dwmac.txt        | 25 ++++++++
>   drivers/net/ethernet/stmicro/stmmac/Kconfig        | 10 ++++
>   drivers/net/ethernet/stmicro/stmmac/Makefile       |  1 +
>   drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c  | 67 ++++++++++++++++++++++
>   drivers/net/ethernet/stmicro/stmmac/stmmac.h       |  3 +
>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |  3 +
>   6 files changed, 109 insertions(+)
>   create mode 100644 Documentation/devicetree/bindings/net/meson-dwmac.txt
>   create mode 100644 drivers/net/ethernet/stmicro/stmmac/dwmac-meson.c
>

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
