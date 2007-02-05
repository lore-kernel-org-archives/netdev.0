From: "Ahmed S. Darwish" <darwish.07@gmail.com>
Subject: [PATCH 2.6.20] wavelan: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 19:00:44 +0200
Message-ID: <20070205170044.GM3896@Ahmed>
References: <20070205165429.GD3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jt@hpl.hp.com, linville@tuxdriver.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932451AbXBERBQ@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070205165429.GD3896@Ahmed>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A trivial patch to use ARRAY_SIZE macro.

Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
---
diff --git a/drivers/net/wireless/wavelan.p.h b/drivers/net/wireless/wavelan.p.h
index 72b646c..fe12c77 100644
--- a/drivers/net/wireless/wavelan.p.h
+++ b/drivers/net/wireless/wavelan.p.h
@@ -450,7 +450,7 @@ static const char	*version	= "wavelan.c : v24 (SMP + wireless extensions) 11/12/
 #define	WATCHDOG_JIFFIES	(512*HZ/100)
 
 /* Macro to get the number of elements in an array */
-#define	NELS(a)				(sizeof(a) / sizeof(a[0]))
+#define	NELS(a)				ARRAY_SIZE(a)
 
 /* ------------------------ PRIVATE IOCTL ------------------------ */
 



-- 
Ahmed S. Darwish
http://darwish-07.blogspot.com
