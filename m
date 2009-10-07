From: Alexandre Cassen <acassen@freebox.fr>
Subject: [PATCH] IPv6: Fix 6RD typo
Date: Wed, 7 Oct 2009 23:45:34 +0200
Message-ID: <20091007214534.GA1800@lnxos.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:60206 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754370AbZJGVqU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 17:46:20 -0400
Received: from smtp2-g21.free.fr (localhost [127.0.0.1])
	by smtp2-g21.free.fr (Postfix) with ESMTP id ABF7A4B010D
	for <netdev@vger.kernel.org>; Wed,  7 Oct 2009 23:45:37 +0200 (CEST)
Received: from mail.lnxos.net (lnxos.staff.proxad.net [213.228.1.83])
	by smtp2-g21.free.fr (Postfix) with ESMTP id D46AA4B011A
	for <netdev@vger.kernel.org>; Wed,  7 Oct 2009 23:45:34 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following fix a small typo.

Signed-off-by: Alexandre Cassen <acassen@freebox.fr>
---
 net/ipv6/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index f561998..a578096 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -171,7 +171,7 @@ config IPV6_SIT
 	  Saying M here will produce a module called sit. If unsure, say Y.
 
 config IPV6_SIT_6RD
-	bool "IPv6: IPv6 Rapid Development (6RD) (EXPERIMENTAL)"
+	bool "IPv6: IPv6 Rapid Deployment (6RD) (EXPERIMENTAL)"
 	depends on IPV6_SIT && EXPERIMENTAL
 	default n
 	---help---
-- 
1.6.0.4

