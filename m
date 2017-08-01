From: Amitoj Kaur Chawla <amitoj1606@gmail.com>
Subject: [PATCH 1/2] atm: adummy: constify attribute_group structure
Date: Tue, 1 Aug 2017 19:57:38 -0400
Message-ID: <20170801235738.GA13517@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: 3chas3@gmail.com, linux-atm-general@lists.sourceforge.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Functions working with attribute_groups provided by <linux/sysfs.h>
work with const attribute_group. These attribute_group structures do not
change at runtime so mark them as const.

File size before:
 text      data     bss     dec     hex filename
 2033      1448       0    3481     d99 drivers/atm/adummy.o

File size after:
 text      data     bss     dec     hex filename
 2129      1352       0    3481     d99 drivers/atm/adummy.o

This change was made with the help of Coccinelle.

Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
---
 drivers/atm/adummy.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/adummy.c b/drivers/atm/adummy.c
index 1fd25e8..da27ddf 100644
--- a/drivers/atm/adummy.c
+++ b/drivers/atm/adummy.c
@@ -71,7 +71,7 @@ static struct attribute *adummy_attrs[] = {
 	NULL
 };
 
-static struct attribute_group adummy_group_attrs = {
+static const struct attribute_group adummy_group_attrs = {
 	.name = NULL, /* We want them in dev's root folder */
 	.attrs = adummy_attrs
 };
-- 
2.7.4
