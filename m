From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH] gigaset: don't enable any debugging output by default
Date: Sat,  5 Dec 2009 19:04:16 +0100 (CET)
Message-ID: <20091205180416.B3629400DE@xenon.ts.pxnet.com>
Cc: Hansjoerg Lipp <hjlipp@web.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:54732 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932874AbZLETBb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Dec 2009 14:01:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When built with debugging support, the Gigaset driver enabled some
debugging messages by default. Change the default to "all off".

Impact: cosmetic
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---

Please merge for 2.6.33 so I can in good conscience encourage people to
build the driver with CONFIG_GIGASET_DEBUG=y. ;-)

Thanks, Tilman

 drivers/isdn/gigaset/common.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/common.c
index c438cfc..a0b85d1 100644
--- a/drivers/isdn/gigaset/common.c
+++ b/drivers/isdn/gigaset/common.c
@@ -29,7 +29,7 @@
 #endif
 
 /* Module parameters */
-int gigaset_debuglevel = DEBUG_DEFAULT;
+int gigaset_debuglevel;
 EXPORT_SYMBOL_GPL(gigaset_debuglevel);
 module_param_named(debug, gigaset_debuglevel, int, S_IRUGO|S_IWUSR);
 MODULE_PARM_DESC(debug, "debug level");
-- 
1.6.5.3.298.g39add

