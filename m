From: Arvind Yadav <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net: usb: qmi_wwan: constify attribute_group structures.
Date: Mon, 10 Jul 2017 13:19:07 +0530
Message-ID: <7567aa802cd3347aab19da6d4af6748f61e08f72.1499672630.git.arvind.yadav.cs@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: bjorn-yOkvZcmFvRU@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

attribute_groups are not supposed to change at runtime. All functions
working with attribute_groups provided by <linux/netdevice.h> work
with const attribute_group. So mark the non-const structs as const.

File size before:
   text	   data	    bss	    dec	    hex	filename
  16831	    464	      0	  17295	   438f	drivers/net/usb/qmi_wwan.o

File size After adding 'const':
   text	   data	    bss	    dec	    hex	filename
  16895	    400	      0	  17295	   438f	drivers/net/usb/qmi_wwan.o

Signed-off-by: Arvind Yadav <arvind.yadav.cs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 5894e3c..b2ddd5c 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -434,7 +434,7 @@ static ssize_t del_mux_store(struct device *d,  struct device_attribute *attr, c
 	NULL,
 };
 
-static struct attribute_group qmi_wwan_sysfs_attr_group = {
+static const struct attribute_group qmi_wwan_sysfs_attr_group = {
 	.name = "qmi",
 	.attrs = qmi_wwan_sysfs_attrs,
 };
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
