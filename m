From: Mauro Dreissig <mukadr@gmail.com>
Subject: [PATCH v2 0/4] Cleanups for rtl871x_ioctl_rtl
Date: Wed, 25 Nov 2015 15:42:38 -0200
Message-ID: <1448473362-12524-1-git-send-email-mukadr@gmail.com>
Cc: Mauro Dreissig <mukadr@gmail.com>
To: Larry.Finger@lwfinger.net, florian.c.schilhabel@googlemail.com,
	gregkh@linuxfoundation.org, devel@driverdev.osuosl.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35604 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbbKYRqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 12:46:36 -0500
Received: by qgec40 with SMTP id c40so37287354qge.2
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 09:46:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This applies some janitorial work to rtl8712 driver.

Mauro Dreissig (4):
  staging: rtl8712: Remove casts between void * and type *
  staging: rtl8712: Rename local variable
  staging: rtl8712: Make error handling check for failure
  staging: rtl8712: Rename local variable

 drivers/staging/rtl8712/rtl871x_ioctl_rtl.c | 492 +++++++++++++---------------
 drivers/staging/rtl8712/rtl871x_ioctl_rtl.h | 123 +++----
 2 files changed, 274 insertions(+), 341 deletions(-)

-- 
2.6.3
