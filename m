From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: jme: remove unused #include <version.h>
Date: Sun, 12 Oct 2008 23:12:54 +0800
Message-ID: <20081012231101.E7EF.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.186]:64517 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753496AbYJLPNA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 11:13:00 -0400
Received: by ti-out-0910.google.com with SMTP id b6so670539tic.23
        for <netdev@vger.kernel.org>; Sun, 12 Oct 2008 08:12:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The file(s) below do not use LINUX_VERSION_CODE nor KERNEL_VERSION.
  drivers/net/jme.c

This patch removes the said #include <version.h>.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 5f9a131..156f159 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -21,7 +21,6 @@
  *
  */

-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
 #include <linux/pci.h>

