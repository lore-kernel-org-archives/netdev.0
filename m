From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 2/3] vhost: initialize log eventfd context pointer
Date: Tue, 23 Feb 2010 18:57:51 +0200
Message-ID: <f383d82104a04b92fe2953a4d8a98425c1ff6cde.1266943453.git.mst@redhat.com>
References: <cover.1266943453.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	ma
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1266943453.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

vq log eventfd context pointer needs to be initialized, otherwise
operation may fail or oops if log is enabled but log eventfd not set by
userspace.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index c767279..d4f8fdf 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -121,6 +121,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
 	vq->kick = NULL;
 	vq->call_ctx = NULL;
 	vq->call = NULL;
+	vq->log_ctx = NULL;
 }
 
 long vhost_dev_init(struct vhost_dev *dev,
-- 
1.7.0.18.g0d53a5
