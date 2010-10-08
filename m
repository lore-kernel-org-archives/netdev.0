From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 2/4] Phonet: advise against enabling the pipe controller
Date: Fri,  8 Oct 2010 17:02:01 +0300
Message-ID: <1286546523-3340-2-git-send-email-remi@remlab.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47819 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758127Ab0JHOCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:02:05 -0400
In-Reply-To: <1286546523-3340-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

As it currently is, the new code path is not compatible with existing
Nokia modems. This would break existing userspace for Nokia modem, such
as the existing oFono ISI driver.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
index 901956a..a4fceb8 100644
--- a/net/phonet/Kconfig
+++ b/net/phonet/Kconfig
@@ -24,4 +24,5 @@ config PHONET_PIPECTRLR
 	  data with Nokia Slim modems like WG2.5 used on ST-Ericsson U8500
 	  platform.
=20
-	  If unsure, say N.
+	  This option is incompatible with older Nokia modems.
+	  Say N here unless you really know what you are doing.
--=20
1.7.0.4

