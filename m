From: Mikko Rapeli <mikko.rapeli@iki.fi>
Subject: [PATCH 47/98] include/uapi/linux/if_pppol2tp.h: include linux/in.h and linux/in6.h
Date: Sat, 30 May 2015 17:38:39 +0200
Message-ID: <1433000370-19509-48-git-send-email-mikko.rapeli@iki.fi>
References: <1433000370-19509-1-git-send-email-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mikko Rapeli <mikko.rapeli@iki.fi>,
	James Chapman <jchapman@katalix.com>, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kapsi.fi ([217.30.184.167]:40653 "EHLO mail.kapsi.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758005AbbE3Ple (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 30 May 2015 11:41:34 -0400
In-Reply-To: <1433000370-19509-1-git-send-email-mikko.rapeli@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ixes userspace compilation errors like:

error: field =E2=80=98addr=E2=80=99 has incomplete type
 struct sockaddr_in addr; /* IP address and port to send to */
                    ^
error: field =E2=80=98addr=E2=80=99 has incomplete type
 struct sockaddr_in6 addr; /* IP address and port to send to */

Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
---
 include/uapi/linux/if_pppol2tp.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_pppol2tp.h b/include/uapi/linux/if_p=
ppol2tp.h
index 163e8ad..4bd1f55 100644
--- a/include/uapi/linux/if_pppol2tp.h
+++ b/include/uapi/linux/if_pppol2tp.h
@@ -16,7 +16,8 @@
 #define _UAPI__LINUX_IF_PPPOL2TP_H
=20
 #include <linux/types.h>
-
+#include <linux/in.h>
+#include <linux/in6.h>
=20
 /* Structure used to connect() the socket to a particular tunnel UDP
  * socket over IPv4.
--=20
2.1.4
