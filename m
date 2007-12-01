From: Sebastian Siewior <netdev@ml.breakpoint.cc>
Subject: [PATCH] [net] xrfm depends on crypto
Date: Sat, 1 Dec 2007 13:19:53 +0100
Message-ID: <20071201121953.GB8048@Chamillionaire.breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: herbert@gondor.apana.org.au, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:42933 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752564AbXLAMTz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 07:19:55 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/built-in.o: In function `xfrm_find_algo':
xfrm_algo.c:(.text+0x61c82): undefined reference to `crypto_has_alg'

Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
---
 net/xfrm/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index 577a4f8..35ed342 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -4,6 +4,7 @@
 config XFRM
        bool
        depends on NET
+       select CRYPTO
 
 config XFRM_USER
 	tristate "Transformation user configuration interface"
-- 
1.5.3.4

