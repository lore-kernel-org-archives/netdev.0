From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH 42/98] include/uapi/linux/if_tunnel.h: include linux/if.h, linux/ip.h and linux/in6.h
Date: Sat, 30 May 2015 17:38:34 +0200
Message-ID: <1433000370-19509-43-git-send-email-mikko.rapeli@iki.fi>
References: <1433000370-19509-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Dmitry Popov <ixaphire@qrator.net>, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:46256 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757940AbbE3PlU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2015 11:41:20 -0400
In-Reply-To: <1433000370-19509-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes userspace compilation errors like:

error: field =E2=80=98iph=E2=80=99 has incomplete type
error: field =E2=80=98prefix=E2=80=99 has incomplete type

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_tunnel.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tun=
nel.h
index bd3cc11..2a36080 100644
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
2.1.4
