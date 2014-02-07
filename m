From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 07/26] drivers: isdn: Move prototype declaration to header
 file platform.h from divasproc.c
Date: Fri, 7 Feb 2014 17:56:21 +0530
Message-ID: <b29a188ce0a77d8e536258ef25745c82492e8f44.1390408515.git.rashika.kheria@gmail.com>
References: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Armin Schindler <mac@melware.de>,
	Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <3cb4d7892ba5a0c0936b3a1e2c9c991a6dbc3229.1390408513.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move prototype declaration of functions to header file
hardware/eicon/platform.h because they are used by more than one file.

This eliminates the following warnings in hardware/eicon/divasmain.c:
drivers/isdn/hardware/eicon/divasmain.c:190:6: warning: no previous pro=
totype for =E2=80=98divas_get_version=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 drivers/isdn/hardware/eicon/divasproc.c |    1 -
 drivers/isdn/hardware/eicon/platform.h  |    1 +
 2 files changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/divasproc.c b/drivers/isdn/har=
dware/eicon/divasproc.c
index 56ce98a..edb7f39 100644
--- a/drivers/isdn/hardware/eicon/divasproc.c
+++ b/drivers/isdn/hardware/eicon/divasproc.c
@@ -34,7 +34,6 @@
=20
=20
 extern PISDN_ADAPTER IoAdapters[MAX_ADAPTER];
-extern void divas_get_version(char *);
 extern void diva_get_vserial_number(PISDN_ADAPTER IoAdapter, char *buf=
);
=20
 /*********************************************************
diff --git a/drivers/isdn/hardware/eicon/platform.h b/drivers/isdn/hard=
ware/eicon/platform.h
index cdfbb19..e861857 100644
--- a/drivers/isdn/hardware/eicon/platform.h
+++ b/drivers/isdn/hardware/eicon/platform.h
@@ -150,6 +150,7 @@ struct _diva_os_timer;
 struct _ISDN_ADAPTER;
=20
 void diva_log_info(unsigned char *, ...);
+void divas_get_version(char *);
=20
 /*
 **  XDI DIDD Interface
--=20
1.7.9.5
