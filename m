From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0771/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:50 +0800
Message-ID: <20160802114450.1072-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, bkenward-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
 computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org,
 m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
 k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/broadcom/b43/sysfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/b43/sysfs.c b/drivers/net/wireless/broadcom/b43/sysfs.c
index 3190493..5b664ff 100644
--- a/drivers/net/wireless/broadcom/b43/sysfs.c
+++ b/drivers/net/wireless/broadcom/b43/sysfs.c
@@ -135,7 +135,7 @@ static ssize_t b43_attr_interfmode_store(struct device *dev,
 	return err ? err : count;
 }
 
-static DEVICE_ATTR(interference, 0644,
+static DEVICE_ATTR(interference, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH,
 		   b43_attr_interfmode_show, b43_attr_interfmode_store);
 
 int b43_sysfs_register(struct b43_wldev *wldev)
-- 
2.9.2
