From: "Randy.Dunlap" <rddunlap@osdl.org>
Subject: [PATCH] 3c515: fix module_param type
Date: Mon, 17 Jan 2005 21:07:00 -0800
Message-ID: <41EC9974.1090209@osdl.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030703000806090001000700"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>, jgarzik <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030703000806090001000700
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

3c515: correct module_param data type (remove "const");

drivers/net/3c515.c:406: warning: return discards qualifiers from 
pointer target type
drivers/net/3c515.c:406: warning: initialization discards qualifiers 
from pointer target type

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
  drivers/net/3c515.c |    2 +-
  1 files changed, 1 insertion(+), 1 deletion(-)

---

--------------030703000806090001000700
Content-Type: text/x-patch;
 name="3c515_modprm.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c515_modprm.patch"


3c515: correct module_param data type (remove "const");

drivers/net/3c515.c:406: warning: return discards qualifiers from pointer target type
drivers/net/3c515.c:406: warning: initialization discards qualifiers from pointer target type

Signed-off-by: Randy Dunlap <rddunlap@osdl.org>

diffstat:=
 drivers/net/3c515.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff -Naurp ./drivers/net/3c515.c~3c515_modprm ./drivers/net/3c515.c
--- ./drivers/net/3c515.c~3c515_modprm	2005-01-10 13:28:51.000000000 -0800
+++ ./drivers/net/3c515.c	2005-01-17 16:17:33.468358720 -0800
@@ -34,7 +34,7 @@ DRV_NAME ".c:v" DRV_VERSION " " DRV_RELD
 /* "Knobs" that adjust features and parameters. */
 /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
    Setting to > 1512 effectively disables this feature. */
-static const int rx_copybreak = 200;
+static int rx_copybreak = 200;
 
 /* Allow setting MTU to a larger size, bypassing the normal ethernet setup. */
 static const int mtu = 1500;

--------------030703000806090001000700--
