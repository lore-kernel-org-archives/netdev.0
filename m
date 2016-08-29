From: robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org
Subject: [PATCH v3 0/5] net/usb: asix driver improvements
Date: Mon, 29 Aug 2016 09:32:14 -0400
Message-ID: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss__41532.5142363601$1472477745$gmane$org@collabora.com>
To: freddy-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, Dean_Jenkins-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org,
        Mark_Craske-nmGgyN9QBj3QT0dZR+AlfA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
        robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org, ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, vpalatin-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org, grundler-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org,
        changchias-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, allan-knRN6Y/kmf1NUHwG+Fw1Kw@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        tremyfr-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, colin.king-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org,
        linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, vpalatin-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Robert Foss <robert.foss-ZGY8ohtN/8qB+jHODAdFcQ@public.gmane.org>

This is a resubmission of v3, since the netdev
mailinlist was not sent the previous submission.

This series improves power management of the asix driver.

 - Suspend/resume support is improved to save needed registers.
 - Device disconnection is improved.
 - Fixes AX88772x resume failures
 - Implementes IEEE 802.3 spec section "22.2.4.1.1 Reset" correctly
 - Fixes AX_CMD_WRITE_MEDIUM_MODE being set incorrectly

Changes since v1:
- Added proper metadata tags to series.
- Added two more patches to series.

Changes since v2:
- Added coverletter
- Tested patches on AX88772A/AX88772B/AX88178/AX88179 hardware

Allan Chou (1):
  net: asix: Fix AX88772x resume failures

Freddy Xin (1):
  net: asix: Add in_pm parameter

Grant Grundler (2):
  net: asix: see 802.3 spec for phy reset
  net: asix: autoneg will set WRITE_MEDIUM reg

Vincent Palatin (1):
  net: asix: Avoid looping when the device is disconnected

 drivers/net/usb/asix.h         |  40 ++-
 drivers/net/usb/asix_common.c  | 212 ++++++++++++----
 drivers/net/usb/asix_devices.c | 450 +++++++++++++++++++++++++++-------
 drivers/net/usb/ax88172a.c     |  29 +-
 4 files changed, 575 insertions(+), 156 deletions(-)

-- 
git-series 0.8.10
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
