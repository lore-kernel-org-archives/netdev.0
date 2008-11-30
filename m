From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH] MAINTAINERS: add netdev to ATM
Date: Sun, 30 Nov 2008 09:23:09 +0100
Message-ID: <1228033389-24415-1-git-send-email-jirislaby@gmail.com>
References: <20081129.204341.88799313.davem@davemloft.net>
Cc: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.wellnetcz.com ([212.24.148.102]:58372 "EHLO
	smtp.wellnetcz.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751085AbYK3IXe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Nov 2008 03:23:34 -0500
In-Reply-To: <20081129.204341.88799313.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> > One fail path in hrz_probe omitted device disable. Fix it.
> > 
> > Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
> 
> Applied, but please post all networking patches to
> netdev@vger.kernel.org, in particular so that they
> get properly tracked at:
> 
> 	http://patchwork.ozlabs.org/project/netdev/list/
> 
> I feel like I type this in at least 10 times a day, so
> people please start making sure netdev is on the CC: for
> all networking patches.

Hmm, I didn't even think this is net related. I would expect such things to
be in drivers/net/ then. Consider the patch below for applying.

--

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
---
 MAINTAINERS |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index e17fa7d..6035710 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -779,6 +779,7 @@ ATM
 P:	Chas Williams
 M:	chas@cmf.nrl.navy.mil
 L:	linux-atm-general@lists.sourceforge.net (subscribers-only)
+L:	netdev@vger.kernel.org
 W:	http://linux-atm.sourceforge.net
 S:	Maintained
 
-- 
1.6.0.4

