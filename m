From: Huang Weiyi <weiyi.huang@gmail.com>
Subject: ucc_geth_ethtool.c: removed duplicated include
Date: Sat, 10 May 2008 09:07:22 +0800
Message-ID: <20080510090517.244A.WEIYI.HUANG@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:28670 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbYEJBH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 21:07:26 -0400
Received: by wa-out-1112.google.com with SMTP id j37so2081565waf.23
        for <netdev@vger.kernel.org>; Fri, 09 May 2008 18:07:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removed duplicated include <asm/uaccess.h> in 
drivers/net/ucc_geth_ethtool.c.

Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>

--- a/drivers/net/ucc_geth_ethtool.c    2008-05-10 08:41:10.000000000 +0800
+++ b/drivers/net/ucc_geth_ethtool.c    2008-05-10 08:41:42.000000000 +0800
@@ -37,7 +37,6 @@
 #include <asm/irq.h>
 #include <asm/uaccess.h>
 #include <asm/types.h>
-#include <asm/uaccess.h>

 #include "ucc_geth.h"
 #include "ucc_geth_mii.h"


