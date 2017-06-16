From: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH v3 0/4] PTP support for macb driver
Date: Fri, 16 Jun 2017 12:58:18 +0100
Message-ID: <1497614298-14074-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rafal Ozieblo <rafalo-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
        Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        <harini.katakam-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>, <andrei.pistirica-UWL1GkI3JZL3oGB3hsPCZA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch series adds support for PTP synchronization protocol
in Cadence GEM driver based on PHC.

v2 changes:
* removed alarm's support
* removed external time stamp support
* removed PTP event interrupt handling
* removed ptp_hw_support flag
* removed all extra sanity checks
* removed unnecessary #ifdef
* fixed coding style and alligment issues
* renamed macb.c to macb_main.c

v3 changes:
* added checking NULL ptr from ptp_clock_register()
* fixed error codes return
* locals list in "upside down Christmas tree" style
* fixed some other issues from review

Rafal Ozieblo (4):
  net: macb: Add support for PTP timestamps in DMA descriptors
  net: macb: Add tsu_clk to device tree
  net: macb: macb.c changed to macb_main.c
  net: macb: Add hardware PTP support

 Documentation/devicetree/bindings/net/macb.txt |    1 +
 drivers/net/ethernet/cadence/Kconfig           |   10 +-
 drivers/net/ethernet/cadence/Makefile          |    5 +
 drivers/net/ethernet/cadence/macb.c            | 3509 -----------------------
 drivers/net/ethernet/cadence/macb.h            |  158 +-
 drivers/net/ethernet/cadence/macb_main.c       | 3646 ++++++++++++++++++++++++
 drivers/net/ethernet/cadence/macb_ptp.c        |  518 ++++
 7 files changed, 4330 insertions(+), 3517 deletions(-)
 delete mode 100644 drivers/net/ethernet/cadence/macb.c
 create mode 100644 drivers/net/ethernet/cadence/macb_main.c
 create mode 100755 drivers/net/ethernet/cadence/macb_ptp.c

-- 
2.4.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
