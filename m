From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: [1/1] connector maintainer/mail update.
Date: Sat, 18 Jul 2009 18:25:33 +0400
Message-ID: <20090718142533.GA1948@ioremap.net>
References: <1247696049-15699-1-git-send-email-vapier@gentoo.org> <20090716101957.GA9586@ioremap.net> <20090717.101550.223298982.davem@davemloft.net> <8bd0f97a0907172045j2cff6987xb7ea0aab438bef9d@mail.gmail.com> <20090717223307.d86a5551.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mike Frysinger <vapier.adi@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from corega.com.ru ([195.178.208.66]:32994 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753149AbZGROZf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Jul 2009 10:25:35 -0400
Content-Disposition: inline
In-Reply-To: <20090717223307.d86a5551.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.

Signed-off-by: Evgeniy Polyakov <zbr@ioremap.net>

diff --git a/Documentation/connector/cn_test.c b/Documentation/connector/cn_test.c
index 6977c17..6344f7b 100644
--- a/Documentation/connector/cn_test.c
+++ b/Documentation/connector/cn_test.c
@@ -1,7 +1,7 @@
 /*
  * 	cn_test.c
  * 
- * 2004-2005 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
  * 
  * This program is free software; you can redistribute it and/or modify
@@ -187,5 +187,5 @@ module_init(cn_test_init);
 module_exit(cn_test_fini);
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
 MODULE_DESCRIPTION("Connector's test module");
diff --git a/Documentation/connector/ucon.c b/Documentation/connector/ucon.c
index d738cde..c5092ad 100644
--- a/Documentation/connector/ucon.c
+++ b/Documentation/connector/ucon.c
@@ -1,7 +1,7 @@
 /*
  * 	ucon.c
  *
- * Copyright (c) 2004+ Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * Copyright (c) 2004+ Evgeniy Polyakov <zbr@ioremap.net>
  *
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/MAINTAINERS b/MAINTAINERS
index c944d61..764ce3b 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1518,6 +1518,13 @@ S:	Supported
 F:	fs/configfs/
 F:	include/linux/configfs.h
 
+CONNECTOR
+P:	Evgeniy Polyakov
+M:	zbr@ioremap.net
+L:	netdev@vger.kernel.org
+S:	Maintained
+F:	drivers/connector/
+
 CONTROL GROUPS (CGROUPS)
 P:	Paul Menage
 M:	menage@google.com
diff --git a/drivers/connector/cn_queue.c b/drivers/connector/cn_queue.c
index c769ef2..b4ad84d 100644
--- a/drivers/connector/cn_queue.c
+++ b/drivers/connector/cn_queue.c
@@ -1,7 +1,7 @@
 /*
  * 	cn_queue.c
  *
- * 2004-2005 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify
diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index fd336c5..b135281 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -1,7 +1,7 @@
 /*
  * 	connector.c
  *
- * 2004-2005 Copyright (c) Evgeniy Polyakov <johnpol@2ka.mipt.ru>
+ * 2004+ Copyright (c) Evgeniy Polyakov <zbr@ioremap.net>
  * All rights reserved.
  *
  * This program is free software; you can redistribute it and/or modify
@@ -33,7 +33,7 @@
 #include <net/sock.h>
 
 MODULE_LICENSE("GPL");
-MODULE_AUTHOR("Evgeniy Polyakov <johnpol@2ka.mipt.ru>");
+MODULE_AUTHOR("Evgeniy Polyakov <zbr@ioremap.net>");
 MODULE_DESCRIPTION("Generic userspace <-> kernelspace connector.");
 
 static u32 cn_idx = CN_IDX_CONNECTOR;


-- 
	Evgeniy Polyakov
