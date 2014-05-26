From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/3]  Some fixes for r8192ee and r8821ae
Date: Mon, 26 May 2014 14:06:03 -0500
Message-ID: <1401131166-6313-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:45675 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751200AbaEZTGZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 15:06:25 -0400
Received: by mail-ob0-f169.google.com with SMTP id vb8so8426609obc.0
        for <netdev@vger.kernel.org>; Mon, 26 May 2014 12:06:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initial testing of r8192ee builds has found two problems. The first of them
is caused by using the same rate-control algorithm as is used by driver rtlwifi
in the main wireless tree. As r8821ae also has the same (not yet reported) problem,
a fix for it is also included.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>

Larry Finger (3):
  staging: r8192ee: Fix kernel WARN splat associated with rate control
  staging: r8192ee: Fix build errors when PCI is not available
  staging: r8821ae: Fix potential problem with rate control registration

 drivers/staging/rtl8192ee/Kconfig | 7 +++++++
 drivers/staging/rtl8192ee/rc.c    | 2 +-
 drivers/staging/rtl8821ae/rc.c    | 2 +-
 3 files changed, 9 insertions(+), 2 deletions(-)

-- 
1.8.4.5
