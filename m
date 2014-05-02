From: George Cherian <george.cherian-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 0/6] Add CPTS support for AM437x
Date: Fri, 2 May 2014 12:01:58 +0530
Message-ID: <1399012324-20737-1-git-send-email-george.cherian@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	<ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>, <tklauser-93Khv+1bN0NyDzI6CaY1VQ@public.gmane.org>, <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	<bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <zonque-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <balbi-l0cyMroinI0@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, <george.cherian-l0cyMroinI0@public.gmane.org>, <t-kristo-l0cyMroinI0@public.gmane.org>,
	<mturquette-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	<galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	<mark.rutland-5wv7dgnIgG8@public.gmane.org>, <pawel.moll-5wv7dgnIgG8@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>, <bcousson-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The series adds CPTS support for AM4372.

Patch 1 - DT changes w.r.t clock changes for AM33xx.
Patch 2 - CPTS clock name harcoding in the driver is removed. 
	  Easier to pass the clock name from dt rather than hardcoding in driver.
	  Also in prepration for DRA7x CPTS support.
Patch 3 - Enable the CPTS support for both DRA7x and AM4372 in the driver.
Patch 4 - Enable the Annexe F for L2 PTP for AM437x and DRA7x.
Patch 5 - Change the default clocksource to dpll_core_m5 
Patch 6 - DT changes for AM4372.


v1 -> v2
	Patch 1 and 2 Re-ordering.
	Seperate TS_BITS define for Hw version V2 and V3

George Cherian (6):
  ARM: dts: am33xx: Add clock names for cpsw and cpts
  drivers: net: cpts: Remove hardcoded clock name for CPTS
  drivers: net: cpsw: Enable CPTS for DRA7xx and AM4372
  drivers: net: cpsw: Enable Annexe F Time sync
  ARM: AM43xx: clk: Change the cpts ref clock source to dpll_core_m5 clk
  ARM: dts: am4372: Add clock names for cpsw and cpts

 arch/arm/boot/dts/am33xx.dtsi  |  2 ++
 arch/arm/boot/dts/am4372.dtsi  |  2 ++
 drivers/clk/ti/clk-43xx.c      | 16 ++++++++++++
 drivers/net/ethernet/ti/cpsw.c | 56 +++++++++++++++++++++++++++++++-----------
 drivers/net/ethernet/ti/cpts.c | 11 +++------
 5 files changed, 66 insertions(+), 21 deletions(-)

-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
