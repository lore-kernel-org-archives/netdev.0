From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v4 44/79] include/uapi/linux/if_pppox.h: include linux/in.h and linux/in6.h
Date: Thu, 15 Oct 2015 07:56:22 +0200
Message-ID: <1444888618-4506-45-git-send-email-mikko.rapeli@iki.fi>
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

=46ixes userspace compilation errors:

error: field =E2=80=98addr=E2=80=99 has incomplete type
 struct sockaddr_in addr; /* IP address and port to send to */

error: field =E2=80=98addr=E2=80=99 has incomplete type
 struct sockaddr_in6 addr; /* IP address and port to send to */

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_pppox.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/uapi/linux/if_pppox.h b/include/uapi/linux/if_pppo=
x.h
index 473c3c4..d37bbb1 100644
--- a/include/uapi/linux/if_pppox.h
+++ b/include/uapi/linux/if_pppox.h
@@ -24,6 +24,8 @@
 #include <linux/if.h>
 #include <linux/if_ether.h>
 #include <linux/if_pppol2tp.h>
+#include <linux/in.h>
+#include <linux/in6.h>
=20
 /* For user-space programs to pick up these definitions
  * which they wouldn't get otherwise without defining __KERNEL__
--=20
2.5.0
