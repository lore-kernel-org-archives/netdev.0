From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH 84/98] include/uapi/linux/atm_zatm.h: include linux/time.h
Date: Sat, 30 May 2015 17:39:16 +0200
Message-ID: <1433000370-19509-85-git-send-email-mikko.rapeli@iki.fi>
References: <1433000370-19509-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>,
	Chas Williams <3chas3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433000370-19509-1-git-send-email-mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46ixes userspace compile error:

error: field =E2=80=98real=E2=80=99 has incomplete type
 struct timeval real;  /* real (wall-clock) time */

Signed-off-by: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
---
 include/uapi/linux/atm_zatm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/atm_zatm.h b/include/uapi/linux/atm_zat=
m.h
index 10f0fa2..adbaa6c 100644
--- a/include/uapi/linux/atm_zatm.h
+++ b/include/uapi/linux/atm_zatm.h
@@ -14,6 +14,7 @@
=20
 #include <linux/atmapi.h>
 #include <linux/atmioc.h>
+#include <linux/time.h>
=20
 #define ZATM_GETPOOL	_IOW('a',ATMIOC_SARPRV+1,struct atmif_sioc)
 						/* get pool statistics */
--=20
2.1.4
