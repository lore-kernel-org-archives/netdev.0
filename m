From: robert.foss@collabora.com
Subject: [PATCH v3 0/5] net/usb: asix driver improvements
Date: Mon, 29 Aug 2016 09:32:14 -0400
Message-ID: <cover.c702ef6af13be7c1282a2f2d3189281fdc327abe.1472155176.git-series.robert.foss__18581.8829726943$1472477735$gmane$org@collabora.com>
To: freddy@asix.com.tw, Dean_Jenkins@mentor.com,
        Mark_Craske@mentor.com, davem@davemloft.net,
        robert.foss@collabora.com, ivecera@redhat.com,
        john.stultz@linaro.org, vpalatin@chromium.org,
        stephen@networkplumber.org, grundler@chromium.org,
        changchias@gmail.com, allan@asix.com.tw, andrew@lunn.ch,
        tremyfr@gmail.com, colin.king@canonical.com,
        linux-usb@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, vpalatin@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bhuna.collabora.co.uk ([46.235.227.227]:52363 "EHLO
        bhuna.collabora.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932750AbcH2Ncd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 Aug 2016 09:32:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Foss <robert.foss@collabora.com>

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
