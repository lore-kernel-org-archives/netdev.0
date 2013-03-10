From: Andreea Hodea <andreea.cristina.hodea@gmail.com>
Subject: [PATCH] eicon: Fixed checkpatch warning
Date: Sun, 10 Mar 2013 14:34:36 +0200
Message-ID: <1362918876-18694-1-git-send-email-hodea_andreea@yahoo.com>
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andreea Hodea <hodea_andreea@yahoo.com>
To: mac@melware.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/isdn/hardware/eicon/diva_didd.c:32:6: warning: symbol
'DRIVERRELEASE_DIDD' was not declared. Should it be static?

Signed-off-by: Andreea Hodea <hodea_andreea@yahoo.com>
---
 drivers/isdn/hardware/eicon/diva_didd.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/isdn/hardware/eicon/diva_didd.c b/drivers/isdn/hardware/eicon/diva_didd.c
index fab6ccf..21468be 100644
--- a/drivers/isdn/hardware/eicon/diva_didd.c
+++ b/drivers/isdn/hardware/eicon/diva_didd.c
@@ -29,7 +29,7 @@ static char *main_revision = "$Revision: 1.13.6.4 $";
 static char *DRIVERNAME =
 	"Eicon DIVA - DIDD table (http://www.melware.net)";
 static char *DRIVERLNAME = "divadidd";
-char *DRIVERRELEASE_DIDD = "2.0";
+static char *DRIVERRELEASE_DIDD = "2.0";
 
 MODULE_DESCRIPTION("DIDD table driver for diva drivers");
 MODULE_AUTHOR("Cytronics & Melware, Eicon Networks");
-- 
1.7.10.4
