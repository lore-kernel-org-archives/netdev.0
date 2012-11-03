From: Lee Jones <lee.jones@linaro.org>
Subject: [PATCH 8/9] isdn: Remove unused variable causing a compile build warning
Date: Sat,  3 Nov 2012 23:02:29 +0100
Message-ID: <1351980150-24145-9-git-send-email-lee.jones@linaro.org>
References: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Lee Jones <lee.jones@linaro.org>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:48038 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756307Ab2KCWC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 18:02:58 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2344547eek.19
        for <netdev@vger.kernel.org>; Sat, 03 Nov 2012 15:02:57 -0700 (PDT)
In-Reply-To: <1351980150-24145-1-git-send-email-lee.jones@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes:
drivers/isdn/i4l/isdn_common.c: In function =E2=80=98isdn_ioctl=E2=80=99=
:
drivers/isdn/i4l/isdn_common.c:1278:8: warning: unused variable =E2=80=98=
s=E2=80=99 [-Wunused-variable]

Cc: Karsten Keil <isdn@linux-pingi.de>
Cc: netdev@vger.kernel.org
Signed-off-by: Lee Jones <lee.jones@linaro.org>
---
 drivers/isdn/i4l/isdn_common.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/isdn/i4l/isdn_common.c b/drivers/isdn/i4l/isdn_com=
mon.c
index 8c610fa..fb90d40 100644
--- a/drivers/isdn/i4l/isdn_common.c
+++ b/drivers/isdn/i4l/isdn_common.c
@@ -1275,7 +1275,6 @@ isdn_ioctl(struct file *file, uint cmd, ulong arg=
)
 	int ret;
 	int i;
 	char __user *p;
-	char *s;
 	union iocpar {
 		char name[10];
 		char bname[22];
--=20
1.7.9.5
