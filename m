From: Brandon Philips <brandon@ifup.org>
Subject: [PATCH] TCP YeAH selects TCP Vegas with Kconfig
Date: Thu, 17 May 2007 11:54:29 -0700
Message-ID: <20070517185429.GA882@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.227]:10835 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756146AbXEQSyu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 14:54:50 -0400
Received: by nz-out-0506.google.com with SMTP id r28so1066556nza
        for <netdev@vger.kernel.org>; Thu, 17 May 2007 11:54:46 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I tried building TCP YeAH into my kernel with TCP Vegas as a module and
the build failed because TCP YeAH depends on Vegas.  This patch makes
Kconfig aware of the YeAH dependency on Vegas.

---
 net/ipv4/Kconfig |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/net/ipv4/Kconfig
===================================================================
--- linux-2.6.orig/net/ipv4/Kconfig
+++ linux-2.6/net/ipv4/Kconfig
@@ -577,6 +577,7 @@ config TCP_CONG_VENO
 config TCP_CONG_YEAH
 	tristate "YeAH TCP"
 	depends on EXPERIMENTAL
+	select TCP_CONG_VEGAS
 	default n
 	---help---
 	YeAH-TCP is a sender-side high-speed enabled TCP congestion control
