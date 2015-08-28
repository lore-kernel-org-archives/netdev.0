From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 1/2] phylib: simplify bogus phy_device_create() result
Date: Fri, 28 Aug 2015 21:34:34 +0300
Message-ID: <36033068.aJZvyM7bre@wasted.cogentembedded.com>
References: <2163825.63u61975nF@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: f.fainelli@gmail.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2163825.63u61975nF@wasted.cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of the bogus string of type casts where ERR_PTR() is enough.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/phy/phy_device.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net-next/drivers/net/phy/phy_device.c
===================================================================
--- net-next.orig/drivers/net/phy/phy_device.c
+++ net-next/drivers/net/phy/phy_device.c
@@ -157,7 +157,7 @@ struct phy_device *phy_device_create(str
 	/* We allocate the device, and initialize the default values */
 	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
 	if (NULL == dev)
-		return (struct phy_device *)PTR_ERR((void *)-ENOMEM);
+		return ERR_PTR(-ENOMEM);
 
 	dev->dev.release = phy_device_release;
 
