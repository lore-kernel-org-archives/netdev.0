From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: pegasus: simplify logical constraint
Date: Wed, 18 May 2016 20:40:51 +0200
Message-ID: <1463596851-3581-1-git-send-email-xypron.glpk@gmx.de>
References: <1463555740.22748.0.camel@suse.com>
Cc: Oliver Neukum <oneukum@suse.com>,
	Guenter Roeck <linux@roeck-us.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Petko Manolov <petkan@mip-labs.com>,
	Petko Manolov <petkan@nucleusys.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463555740.22748.0.camel@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If !count is true, count < 4 is also true.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/usb/pegasus.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/pegasus.c b/drivers/net/usb/pegasus.c
index 36cd7f0..9bbe0161 100644
--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -473,7 +473,7 @@ static void read_bulk_callback(struct urb *urb)
 		goto goon;
 	}
 
-	if (!count || count < 4)
+	if (count < 4)
 		goto goon;
 
 	rx_status = buf[count - 2];
-- 
2.1.4
