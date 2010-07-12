From: Joe Perches <joe@perches.com>
Subject: [PATCH 10/36] drivers/isdn: Remove unnecessary casts of private_data
Date: Mon, 12 Jul 2010 13:50:02 -0700
Message-ID: <3dced1fd71a6f9b10f10cb2f47c88e3767a6e6cf.1278967120.git.joe@perches.com>
References: <cover.1278967120.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org, Karsten Keil <isdn@linux-pingi.de>,
	netdev@vger.kernel.org
To: Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1278967120.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/isdn/capi/capi.c           |    6 +++---
 drivers/isdn/hysdn/hysdn_proclog.c |    2 +-
 drivers/isdn/i4l/isdn_ppp.c        |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/capi/capi.c b/drivers/isdn/capi/capi.c
index 0cabe31..c2d4ba4 100644
--- a/drivers/isdn/capi/capi.c
+++ b/drivers/isdn/capi/capi.c
@@ -691,7 +691,7 @@ unlock_out:
 static ssize_t
 capi_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 {
-	struct capidev *cdev = (struct capidev *)file->private_data;
+	struct capidev *cdev = file->private_data;
 	struct sk_buff *skb;
 	size_t copied;
 	int err;
@@ -726,7 +726,7 @@ capi_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 static ssize_t
 capi_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
 {
-	struct capidev *cdev = (struct capidev *)file->private_data;
+	struct capidev *cdev = file->private_data;
 	struct sk_buff *skb;
 	u16 mlen;
 
@@ -773,7 +773,7 @@ capi_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos
 static unsigned int
 capi_poll(struct file *file, poll_table * wait)
 {
-	struct capidev *cdev = (struct capidev *)file->private_data;
+	struct capidev *cdev = file->private_data;
 	unsigned int mask = 0;
 
 	if (!cdev->ap.applid)
diff --git a/drivers/isdn/hysdn/hysdn_proclog.c b/drivers/isdn/hysdn/hysdn_proclog.c
index e83f6fd..c58a72d 100644
--- a/drivers/isdn/hysdn/hysdn_proclog.c
+++ b/drivers/isdn/hysdn/hysdn_proclog.c
@@ -157,7 +157,7 @@ hysdn_log_write(struct file *file, const char __user *buf, size_t count, loff_t
 	int found = 0;
 	unsigned char *cp, valbuf[128];
 	long base = 10;
-	hysdn_card *card = (hysdn_card *) file->private_data;
+	hysdn_card *card = file->private_data;
 
 	if (count > (sizeof(valbuf) - 1))
 		count = sizeof(valbuf) - 1;	/* limit length */
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 8c46bae..fe824e0 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -477,7 +477,7 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 	struct isdn_ppp_comp_data data;
 	void __user *argp = (void __user *)arg;
 
-	is = (struct ippp_struct *) file->private_data;
+	is = file->private_data;
 	lp = is->lp;
 
 	if (is->debug & 0x1)
-- 
1.7.1.337.g6068.dirty
