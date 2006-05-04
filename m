From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/1] connector: export cn_already_initialized.
Date: Thu, 4 May 2006 16:24:22 +0400
Message-ID: <20060504122421.GA8576@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:442 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932229AbWEDMYn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 08:24:43 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Some modules depend on that value, although it was initially introduced
for in-kernel static build.

No in-kernel users require it to be exported, so if you do think it
should not be exported I will force external module changes.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -486,3 +486,4 @@ module_exit(cn_fini);
 EXPORT_SYMBOL_GPL(cn_add_callback);
 EXPORT_SYMBOL_GPL(cn_del_callback);
 EXPORT_SYMBOL_GPL(cn_netlink_send);
+EXPORT_SYMBOL_GPL(cn_already_initialized);


-- 
	Evgeniy Polyakov
