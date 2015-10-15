From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH v4 40/79] include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h
Date: Thu, 15 Oct 2015 07:56:18 +0200
Message-ID: <1444888618-4506-41-git-send-email-mikko.rapeli@iki.fi>
References: <1444888618-4506-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mikko.rapeli@iki.fi, "David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444888618-4506-1-git-send-email-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46ixes userspace compilation errors like:

error: field =E2=80=98iph=E2=80=99 has incomplete type
error: field =E2=80=98prefix=E2=80=99 has incomplete type

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_tunnel.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tun=
nel.h
index af4de90..8afe695 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -2,6 +2,9 @@
 #define _UAPI_IF_TUNNEL_H_
=20
 #include <linux/types.h>
+#include <linux/if.h>
+#include <linux/ip.h>
+#include <linux/in6.h>
 #include <asm/byteorder.h>
=20
=20
--=20
2.5.0
