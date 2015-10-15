From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v4 39/79] include/uapi/linux/if_pppox.h: include linux/if.h
Date: Thu, 15 Oct 2015 07:56:17 +0200
Message-ID: <1444888618-4506-40-git-send-email-mikko.rapeli@iki.fi>
References: <1444888618-4506-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mikko.rapeli@iki.fi, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444888618-4506-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ixes userspace compilation error:

error: =E2=80=98IFNAMSIZ=E2=80=99 undeclared here (not in a function)

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
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
2.5.0
