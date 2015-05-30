From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: [PATCH 41/98] include/uapi/linux/if_pppox.h: include linux/if.h
Date: Sat, 30 May 2015 17:38:33 +0200
Message-ID: <1433000370-19509-42-git-send-email-mikko.rapeli@iki.fi>
References: <1433000370-19509-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1433000370-19509-1-git-send-email-mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46ixes userspace compilation error:

error: =E2=80=98IFNAMSIZ=E2=80=99 undeclared here (not in a function)

Signed-off-by: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
---
 include/uapi/linux/if_pppox.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppo=
x.h
index e128769..473c3c4 100644
--- a/include/uapi/linux/if_pppox.h
+++ b/include/uapi/linux/if_pppox.h
@@ -21,6 +21,7 @@
 #include <asm/byteorder.h>
=20
 #include <linux/socket.h>
+#include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_pppol2tp.h>
=20
--=20
2.1.4
