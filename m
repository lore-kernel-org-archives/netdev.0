From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH net next] myri10ge: fix compile error
Date: Fri, 17 Apr 2009 13:14:37 -0400
Message-ID: <49E8B8FD.8060100@myri.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000700000102000808000306"
Cc: netdev <netdev@vger.kernel.org>, Brice Goglin <brice@myri.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1912 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753297AbZDQROn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Apr 2009 13:14:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000700000102000808000306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

A compilation error snuck into 2d90b0aa3bc484189940444bcddcbe0ebbb53af5
due to an over-zealous indent script removing spaces around array
initialization ellipsis.  The attached patch fixes the myri10ge
compilation in net-next.

Thanks,

Drew


Signed-off-by: Andrew Gallatin <gallatin@myri.com>


--------------000700000102000808000306
Content-Type: text/x-diff;
 name="fix_myri10ge_compile.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="fix_myri10ge_compile.diff"

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 291944d..140794a 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -269,7 +269,7 @@ MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name");
 
 #define MYRI10GE_MAX_BOARDS 8
 static char *myri10ge_fw_names[MYRI10GE_MAX_BOARDS] =
-    {[0...(MYRI10GE_MAX_BOARDS - 1)] = NULL };
+    {[0 ... (MYRI10GE_MAX_BOARDS - 1)] = NULL };
 module_param_array_named(myri10ge_fw_names, myri10ge_fw_names, charp, NULL,
 			 0444);
 MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image names per board");

--------------000700000102000808000306--
