From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 00/22] staging: rtl87232bs: Fix errors and warnings detected by Smatch
Date: Sat,  8 Apr 2017 11:07:23 -0500
Message-ID: <20170408160745.14328-1-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        hdegoede@redhat.com, hadess@hadess.net, jes.sorensen@gmail.com,
        Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35826 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752338AbdDHQID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 12:08:03 -0400
Received: by mail-oi0-f68.google.com with SMTP id g204so6268459oib.2
        for <netdev@vger.kernel.org>; Sat, 08 Apr 2017 09:08:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A number of routines have indenting, off by one, and possible usage
while null warnings or errors listed by Smatch. This set of patches
fix all but one of these, and it is in code that will be removed in a
subsequent patch.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (22):
  staging: rtl8723bs: Fix indenting warning in os_dep/xmit_linux.c
  staging: rtl8723bs: Fix indenting warning in os_dep/rtw_proc.c
  staging: rtl8723bs: Fix dereference before check warning in
    os_dep/recv_linux.c
  staging: rtl8723bs: Fix indenting warning in os_dep/os_intfs.c
  staging: rtl8723bs: Fix indenting mistake in os_dep/mlme_linux.c
  staging: rtl8723bs: Fix various errors in os_dep/ioctl_cfg80211.c
  staging: rtl8723bs: Fix potential usage while NULL error in
    hal/rtl8723b_hal_init.c
  staging: rtl8723bs: Fix indenting problems in hal/HalHWImg8723B_BB.c
  staging: rtl8723bs: Fix indening problem in hal/hal_com_phycfg.c
  staging: rtl8723bs: Fix indenting problem for hal/hal_com.c
  staging: rtl8723bs: Fix indenting problems in core/rtw_xmit.c
  staging: rtl8723bs: Fix possible usage of NULL pointer in
    core/rtw_debug.c
  staging: rtl8723bs: Fix indenting mistake in core/rtw_ap.c
  staging: rtl8723bs: Fix indenting mistakes in core/rtw_ieee80211.c
  staging: rtl8723bs: Fix indenting mistakes in core/rtw_mlme.c
  staging: rtl8723bs: Fix some indenting problems and a potential data
    overrun
  staging: rtl8723bs: Fix indenting problem in core/rtw_sta_mgt.c
  staging: rtl8723bs: Fix some white-space errors in core/rtw_security.c
  staging: rtl8723bs: Fix white-space errors in core/rtw_recv.c
  staging rtl8723bs: Fix indenting errors and an off-by-one mistake in
    core/rtw_mlme_ext.c
  staging: rtl8723bs: Fix indenting problems in core/rtw_odm.c
  staging: rtlwifi: Fix indenting error in core/rtw_pwrctrl.c

 drivers/staging/rtl8723bs/core/rtw_ap.c           |  99 +++--
 drivers/staging/rtl8723bs/core/rtw_debug.c        |   1 -
 drivers/staging/rtl8723bs/core/rtw_ieee80211.c    |  13 +-
 drivers/staging/rtl8723bs/core/rtw_mlme.c         |  37 +-
 drivers/staging/rtl8723bs/core/rtw_mlme_ext.c     |  25 +-
 drivers/staging/rtl8723bs/core/rtw_odm.c          |  10 +-
 drivers/staging/rtl8723bs/core/rtw_pwrctrl.c      |   2 +-
 drivers/staging/rtl8723bs/core/rtw_recv.c         |  21 +-
 drivers/staging/rtl8723bs/core/rtw_security.c     | 469 +++++++++++-----------
 drivers/staging/rtl8723bs/core/rtw_sta_mgt.c      |   2 +-
 drivers/staging/rtl8723bs/core/rtw_wlan_util.c    |  10 +-
 drivers/staging/rtl8723bs/core/rtw_xmit.c         |  10 +-
 drivers/staging/rtl8723bs/hal/HalHWImg8723B_BB.c  |   6 +-
 drivers/staging/rtl8723bs/hal/hal_com.c           |  10 +-
 drivers/staging/rtl8723bs/hal/hal_com_phycfg.c    |   2 +-
 drivers/staging/rtl8723bs/hal/rtl8723b_hal_init.c |  13 +-
 drivers/staging/rtl8723bs/os_dep/ioctl_cfg80211.c |  38 +-
 drivers/staging/rtl8723bs/os_dep/ioctl_linux.c    |   2 +-
 drivers/staging/rtl8723bs/os_dep/mlme_linux.c     |   4 +-
 drivers/staging/rtl8723bs/os_dep/os_intfs.c       |   2 +-
 drivers/staging/rtl8723bs/os_dep/recv_linux.c     |   3 +-
 drivers/staging/rtl8723bs/os_dep/rtw_proc.c       |   3 +-
 drivers/staging/rtl8723bs/os_dep/xmit_linux.c     |   2 +-
 23 files changed, 375 insertions(+), 409 deletions(-)

-- 
2.12.0
