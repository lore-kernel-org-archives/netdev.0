From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 4/4] Phonet: mark the pipe controller as EXPERIMENTAL
Date: Fri,  8 Oct 2010 17:02:03 +0300
Message-ID: <1286546523-3340-4-git-send-email-remi@remlab.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
 <1286546523-3340-2-git-send-email-remi@remlab.net>
 <1286546523-3340-3-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:47817 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758140Ab0JHOCF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 10:02:05 -0400
In-Reply-To: <1286546523-3340-3-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

There are a bunch of issues that need to be fixed, including:
 - GFP_KERNEL allocations from atomic context
   (and GFP_ATOMIC in process context),
 - abuse of the setsockopt() call convention,
 - unprotected/unlocked static variables...

IMHO, we will need to alter the userspace ABI when we fix it. So mark
the configuration option as EXPERIMENTAL for the time being (or should
it be BROKEN instead?).

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 net/phonet/Kconfig |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/phonet/Kconfig b/net/phonet/Kconfig
index a4fceb8..0d9b8a2 100644
--- a/net/phonet/Kconfig
+++ b/net/phonet/Kconfig
@@ -16,8 +16,8 @@ config PHONET
 	  will be called phonet. If unsure, say N.
=20
 config PHONET_PIPECTRLR
-	bool "Phonet Pipe Controller"
-	depends on PHONET
+	bool "Phonet Pipe Controller (EXPERIMENTAL)"
+	depends on PHONET && EXPERIMENTAL
 	default N
 	help
 	  The Pipe Controller implementation in Phonet stack to support Pipe
--=20
1.7.0.4

