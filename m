From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/2] Fix problems with earlier patches
Date: Fri, 20 Dec 2013 14:58:43 -0600
Message-ID: <1387573126-28907-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:51934 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751383Ab3LTU7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 15:59:03 -0500
Received: by mail-pb0-f42.google.com with SMTP id uo5so3093339pbc.15
        for <netdev@vger.kernel.org>; Fri, 20 Dec 2013 12:59:02 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent set of patches revealed that a line of code had been incorrectly
removed in an earlier edit. That line is added back. In addition, a configuration
problem resulted in a number of "unused variable" warnings.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (2):
  staging: r8188eu: Restore line that was incorrectly removed
  staging: r8188eu: Fix unused variable warnings

 drivers/staging/rtl8188eu/core/rtw_ap.c        | 12 ------------
 drivers/staging/rtl8188eu/core/rtw_debug.c     |  1 -
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c  |  8 --------
 drivers/staging/rtl8188eu/core/rtw_p2p.c       |  4 ++++
 drivers/staging/rtl8188eu/core/rtw_recv.c      |  1 -
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c   |  4 ----
 drivers/staging/rtl8188eu/core/rtw_xmit.c      |  8 --------
 drivers/staging/rtl8188eu/os_dep/ioctl_linux.c |  1 -
 8 files changed, 4 insertions(+), 35 deletions(-)

-- 
1.8.4
