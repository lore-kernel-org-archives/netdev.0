From: Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>
Subject: [PATCH] kaweth: print correct debug ptr
Date: Thu, 11 Oct 2012 17:22:03 +0100
Message-ID: <20121011162158.2432.70215.stgit@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>

We nowdays copy the buffer and free fw->data, so make the debug printk use
the right thing.

Signed-off-by: Alan Cox <alan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---

 drivers/net/usb/kaweth.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index c75e11e..afb117c 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -424,7 +424,7 @@ static int kaweth_download_firmware(struct kaweth_device *kaweth,
 
 	netdev_dbg(kaweth->net,
 		   "Downloading firmware at %p to kaweth device at %p\n",
-		   fw->data, kaweth);
+		   kaweth->firmware_buf, kaweth);
 	netdev_dbg(kaweth->net, "Firmware length: %d\n", data_len);
 
 	return kaweth_control(kaweth,

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
