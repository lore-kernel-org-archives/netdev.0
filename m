From: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/6] nbd: make device_attribute const
Date: Mon, 21 Aug 2017 17:13:08 +0530
Message-ID: <1503315792-14837-3-git-send-email-bhumirks@gmail.com>
References: <1503315792-14837-1-git-send-email-bhumirks@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: julia.lawall-L2FTfq7BK8M@public.gmane.org, rjw-LthD3rsA81gm4RdzfppkhA@public.gmane.org, lenb-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, jbacik-b10kYP2dOMg@public.gmane.org,
 jikos-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, benjamin.tissoires-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, manish.chopra-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
 rahul.verma-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Dept-GELinuxNICDev-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org,
 harish.patil-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, cascardo-DmMZpsCg3uxeGPcbtGPokg@public.gmane.org, don-rBL4DdiBytkIdKJ7tpkyPg@public.gmane.org,
 dvhart-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, andy-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, sre-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
 linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-block-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
 linux-input-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 platform-driver-x86-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-pm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1503315792-14837-1-git-send-email-bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/options/nbd-general>,
 <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nbd-general>
List-Post: <mailto:nbd-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nbd-general>,
 <mailto:nbd-general-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: nbd-general-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Make this const as is is only passed as an argument to the
function device_create_file and device_remove_file and the corresponding
arguments are of type const.
Done using Coccinelle

Signed-off-by: Bhumika Goyal <bhumirks-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/block/nbd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/block/nbd.c b/drivers/block/nbd.c
index 5bdf923..49d7763 100644
--- a/drivers/block/nbd.c
+++ b/drivers/block/nbd.c
@@ -165,7 +165,7 @@ static ssize_t pid_show(struct device *dev,
 	return sprintf(buf, "%d\n", task_pid_nr(nbd->task_recv));
 }
 
-static struct device_attribute pid_attr = {
+static const struct device_attribute pid_attr = {
 	.attr = { .name = "pid", .mode = S_IRUGO},
 	.show = pid_show,
 };
-- 
1.9.1


------------------------------------------------------------------------------
Check out the vibrant tech community on one of the world's most
engaging tech sites, Slashdot.org! http://sdm.link/slashdot
