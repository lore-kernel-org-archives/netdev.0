From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/9 RESENT] Various patches for r8188eu
Date: Fri, 18 Oct 2013 16:31:49 -0500
Message-ID: <5261A8C5.5010606@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	devel@driverdev.osuosl.org
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:49710 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755519Ab3JRVbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 17:31:51 -0400
Received: by mail-ob0-f178.google.com with SMTP id uz6so3607122obc.9
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 14:31:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first of these patches fixes a problem noted for the latest version of
NetworkManager. Without it, the device is not recognized as a wireless unit.

The remainder fix various sparse warnings. All such warnings are cleared
except for a false positive regarging locking. The code is OK there.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Larry Finger (9):
   staging: r8188eu: Set device type to wlan
   staging: r8188eu: Fix Sparse warnings in rtw_wlan_util
   staging: r8188eu: Fix sparse warnings in ioctl_linux.c
   staging: r8188eu: Fix sparse warnings in rtw_ieee80211.c
   staging: r8188eu: Fix sparse warnings in rtl8188e.cmd.c
   staging: r8188eu: Fix sparse warnings in rtw_mlme_ext.c
   staging: r8188eu: Fix sparse warnings in rtl_p2p.c
   staging: r8188eu: Fix sparse warnings in rtw_xmit.c
   staging: r8188eu: Fix sparse warnings in rtw_br_ext.c

  drivers/staging/rtl8188eu/core/rtw_br_ext.c    | 52 +++++++++++++++-----------
  drivers/staging/rtl8188eu/core/rtw_mlme_ext.c  | 41 ++++++++++----------
  drivers/staging/rtl8188eu/core/rtw_p2p.c       |  8 ++--
  drivers/staging/rtl8188eu/core/rtw_wlan_util.c |  2 +-
  drivers/staging/rtl8188eu/core/rtw_xmit.c      |  2 +-
  drivers/staging/rtl8188eu/hal/rtl8188e_cmd.c   |  8 ++--
  drivers/staging/rtl8188eu/include/ieee80211.h  | 16 ++++----
  drivers/staging/rtl8188eu/os_dep/ioctl_linux.c | 20 +++++-----
  drivers/staging/rtl8188eu/os_dep/os_intfs.c    |  5 +++
  9 files changed, 85 insertions(+), 69 deletions(-)

-- 
1.8.4
