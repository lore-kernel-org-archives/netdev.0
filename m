From: Michal Marek <mmarek@suse.cz>
Subject: [PATCH 19/34] rt2x00: Drop __TIME__ usage
Date: Tue,  5 Apr 2011 16:59:06 +0200
Message-ID: <1302015561-21047-20-git-send-email-mmarek@suse.cz>
References: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Cc: linux-kernel@vger.kernel.org, Ivo van Doorn <IvDoorn@gmail.com>,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kbuild@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1302015561-21047-1-git-send-email-mmarek@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The kernel already prints its build timestamp during boot, no need to
repeat it in random drivers and produce different object files each
time.

Cc: Ivo van Doorn <IvDoorn@gmail.com>
Cc: Gertjan van Wingerde <gwingerde@gmail.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Michal Marek <mmarek@suse.cz>
---
 drivers/net/wireless/rt2x00/rt2x00debug.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00debug.c b/drivers/net/wireless/rt2x00/rt2x00debug.c
index c92db32..66166ef 100644
--- a/drivers/net/wireless/rt2x00/rt2x00debug.c
+++ b/drivers/net/wireless/rt2x00/rt2x00debug.c
@@ -568,7 +568,6 @@ static struct dentry *rt2x00debug_create_file_driver(const char *name,
 	blob->data = data;
 	data += sprintf(data, "driver:\t%s\n", intf->rt2x00dev->ops->name);
 	data += sprintf(data, "version:\t%s\n", DRV_VERSION);
-	data += sprintf(data, "compiled:\t%s %s\n", __DATE__, __TIME__);
 	blob->size = strlen(blob->data);
 
 	return debugfs_create_blob(name, S_IRUSR, intf->driver_folder, blob);
-- 
1.7.4.1
