From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v4 60/79] include/uapi/linux/atm_zatm.h: include linux/time.h
Date: Thu, 15 Oct 2015 07:56:38 +0200
Message-ID: <1444888618-4506-61-git-send-email-mikko.rapeli@iki.fi>
References: <1444888618-4506-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mikko.rapeli@iki.fi, Chas Williams <3chas3@gmail.com>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444888618-4506-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ixes userspace compile error:

error: field =E2=80=98real=E2=80=99 has incomplete type
 struct timeval real;  /* real (wall-clock) time */

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
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
2.5.0
