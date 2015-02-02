From: kbuild test robot <fengguang.wu@intel.com>
Subject: [PATCH target] vhost/scsi: vhost_skip_iovec_bytes() can be static
Date: Mon, 2 Feb 2015 14:25:21 +0800
Message-ID: <20150202062521.GA18113@snb>
References: <201502021411.KBLYtCzS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, "Michael S. Tsirkin" <mst@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201502021411.KBLYtCzS%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/vhost/scsi.c:1081:5: sparse: symbol 'vhost_skip_iovec_bytes' was not declared. Should it be static?

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 scsi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/vhost/scsi.c b/drivers/vhost/scsi.c
index d888bd9..8ac003f 100644
--- a/drivers/vhost/scsi.c
+++ b/drivers/vhost/scsi.c
@@ -1078,7 +1078,7 @@ vhost_scsi_send_bad_target(struct vhost_scsi *vs,
 		pr_err("Faulted on virtio_scsi_cmd_resp\n");
 }
 
-int vhost_skip_iovec_bytes(size_t bytes, int max_niov,
+static int vhost_skip_iovec_bytes(size_t bytes, int max_niov,
 			   struct iovec *iov_in, size_t off_in,
 			   struct iovec **iov_out, size_t *off_out)
 {
