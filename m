From: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 0/4] add support for impedance control for TI dp83867 phy and fix 2nd ethernet on dra72 rev C evm
Date: Tue, 4 Oct 2016 18:26:03 +0530
Message-ID: <20161004125607.10569-1-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Russell King <linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>,
        Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for configurable impedance control for TI dp83867
phy via devicetree. More documentation in [1].
CPSW second ethernet is not working, fix it by enabling
impedance configuration on the phy.

Verified the patch on DRA72 Rev C evm, logs at [2]. Also pushed
a branch [3] for others to test.

Changes from initial version:
* As per Sekhar's comment, instead of passing impedance values,
  change to max and min impedance from DT
* Adopted phy_read_mmd_indirect() to cunnrent implementation.
* Corrected the phy delay timings to the optimal value.

[1] - http://www.ti.com/lit/ds/symlink/dp83867ir.pdf
[2] - http://pastebin.ubuntu.com/23274616/
[3] - git://git.ti.com/~mugunthanvnm/ti-linux-kernel/linux.git dp83867-v2

Mugunthan V N (4):
  net: phy: dp83867: Add documentation for optional impedance control
  net: phy: dp83867: add support for MAC impedance configuration
  ARM: dts: dra72-evm-revc: fix correct phy delay and impedance settings
  ARM: dts: dra72-evm-revc: fix correct phy delay

 .../devicetree/bindings/net/ti,dp83867.txt         | 12 ++++++++++
 arch/arm/boot/dts/dra72-evm-revc.dts               | 10 ++++----
 drivers/net/phy/dp83867.c                          | 28 ++++++++++++++++++++++
 3 files changed, 46 insertions(+), 4 deletions(-)

-- 
2.10.0.372.g6fe1b14

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
