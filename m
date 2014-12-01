From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH v8 50/50] virtio: drop VIRTIO_F_VERSION_1 from drivers
Date: Mon, 1 Dec 2014 18:06:59 +0200
Message-ID: <1417449619-24896-51-git-send-email-mst@redhat.com>
References: <1417449619-24896-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, cornelia.huck@de.ibm.com,
	rusty@au1.ibm.com, nab@linux-iscsi.org, pbonzini@redhat.com,
	thuth@linux.vnet.ibm.com, dahi@linux.vnet.ibm.com,
	Rusty Russell <rusty@rustcorp.com.au>,
	Amit Shah <amit.shah@redhat.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417449619-24896-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Core activates this bit automatically now,
drop it from drivers that set it explicitly.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/block/virtio_blk.c    | 1 -
 drivers/char/virtio_console.c | 1 -
 drivers/net/virtio_net.c      | 1 -
 drivers/scsi/virtio_scsi.c    | 1 -
 4 files changed, 4 deletions(-)

diff --git a/drivers/block/virtio_blk.c b/drivers/block/virtio_blk.c
index 1f8b111..1fb9e09 100644
--- a/drivers/block/virtio_blk.c
+++ b/drivers/block/virtio_blk.c
@@ -836,7 +836,6 @@ static unsigned int features[] = {
 	VIRTIO_BLK_F_RO, VIRTIO_BLK_F_BLK_SIZE,
 	VIRTIO_BLK_F_TOPOLOGY,
 	VIRTIO_BLK_F_MQ,
-	VIRTIO_F_VERSION_1,
 };
 
 static struct virtio_driver virtio_blk = {
diff --git a/drivers/char/virtio_console.c b/drivers/char/virtio_console.c
index 775c898..6cc832b 100644
--- a/drivers/char/virtio_console.c
+++ b/drivers/char/virtio_console.c
@@ -2130,7 +2130,6 @@ static struct virtio_device_id id_table[] = {
 static unsigned int features[] = {
 	VIRTIO_CONSOLE_F_SIZE,
 	VIRTIO_CONSOLE_F_MULTIPORT,
-	VIRTIO_F_VERSION_1,
 };
 
 static struct virtio_device_id rproc_serial_id_table[] = {
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 9ab3c50..b8bd719 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -2004,7 +2004,6 @@ static unsigned int features[] = {
 	VIRTIO_NET_F_GUEST_ANNOUNCE, VIRTIO_NET_F_MQ,
 	VIRTIO_NET_F_CTRL_MAC_ADDR,
 	VIRTIO_F_ANY_LAYOUT,
-	VIRTIO_F_VERSION_1,
 };
 
 static struct virtio_driver virtio_net_driver = {
diff --git a/drivers/scsi/virtio_scsi.c b/drivers/scsi/virtio_scsi.c
index d9ec806..2308278 100644
--- a/drivers/scsi/virtio_scsi.c
+++ b/drivers/scsi/virtio_scsi.c
@@ -1085,7 +1085,6 @@ static unsigned int features[] = {
 	VIRTIO_SCSI_F_HOTPLUG,
 	VIRTIO_SCSI_F_CHANGE,
 	VIRTIO_SCSI_F_T10_PI,
-	VIRTIO_F_VERSION_1,
 };
 
 static struct virtio_driver virtio_scsi_driver = {
-- 
MST
