From: Dave Jones <davej@codemonkey.org.uk>
Subject: Make DST_CACHE a silent config option
Date: Mon, 21 Mar 2016 18:37:22 -0400
Message-ID: <20160321223722.GA26702@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arcturus.aphlor.org ([188.246.204.175]:37350 "EHLO
	arcturus.aphlor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758AbcCUWh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2016 18:37:26 -0400
Received: from [209.6.119.210] (helo=wopr.kernelslacker.org)
	by arcturus.aphlor.org with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.86_2)
	(envelope-from <davej@codemonkey.org.uk>)
	id 1ai8Rv-0007Ks-I4
	for netdev@vger.kernel.org; Mon, 21 Mar 2016 22:37:24 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 911362c70d ("net: add dst_cache support") added a new
kconfig option that gets selected by other networking options.
It seems the intent wasn't to offer this as a user-selectable
option given the lack of help text, so this patch converts it
to a silent option.

Signed-off-by: Dave Jones <davej@codemonkey.org.uk>

diff --git a/net/Kconfig b/net/Kconfig
index e13449870d06..a8934d8c8fda 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -397,7 +397,7 @@ config LWTUNNEL
 	  with light weight tunnel state associated with fib routes.
 
 config DST_CACHE
-	bool "dst cache"
+	bool
 	default n
 
 config NET_DEVLINK
