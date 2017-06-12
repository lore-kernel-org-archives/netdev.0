From: Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v1 0/2] Add support for Broadcom DTE based PTP clock
Date: Mon, 12 Jun 2017 13:25:59 -0700
Message-ID: <1497299161-6458-1-git-send-email-arun.parameswaran@broadcom.com>
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bcm-kernel-feedback-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
        Arun Parameswaran <arun.parameswaran-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset adds support for the DTE based PTP clock for Broadcom SoCs.

The DTE nco based PTP clock can be used in both wired and wireless networks
for precision time-stmaping purposes.

Arun Parameswaran (2):
  dt-binding: ptp: add bindings document for dte based ptp clock
  ptp: Add a ptp clock driver for Broadcom DTE

 .../devicetree/bindings/ptp/brcm,ptp-dte.txt       |  13 +
 drivers/ptp/Kconfig                                |  16 +
 drivers/ptp/Makefile                               |   1 +
 drivers/ptp/ptp_dte.c                              | 353 +++++++++++++++++++++
 4 files changed, 383 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/ptp/brcm,ptp-dte.txt
 create mode 100644 drivers/ptp/ptp_dte.c

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
