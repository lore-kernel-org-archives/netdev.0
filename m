From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 1/3] vhost: src file renames
Date: Thu, 2 May 2013 04:45:36 +0300
Message-ID: <dd82beeeb355468cc1ec180142a2085d6477482a.1367459046.git.mst@redhat.com>
References: <cover.1367459045.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <cover.1367459045.git.mst@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Move tcm_vhost.c -> scsi.c

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/Makefile                | 1 +
 drivers/vhost/{tcm_vhost.c => scsi.c} | 0
 2 files changed, 1 insertion(+)
 rename drivers/vhost/{tcm_vhost.c => scsi.c} (100%)

diff --git a/drivers/vhost/Makefile b/drivers/vhost/Makefile
index a27b053..6ea9cec 100644
--- a/drivers/vhost/Makefile
+++ b/drivers/vhost/Makefile
@@ -2,3 +2,4 @@ obj-$(CONFIG_VHOST_NET) += vhost_net.o
 vhost_net-y := vhost.o net.o
 
 obj-$(CONFIG_TCM_VHOST) += tcm_vhost.o
+tcm_vhost-y := scsi.o
diff --git a/drivers/vhost/tcm_vhost.c b/drivers/vhost/scsi.c
similarity index 100%
rename from drivers/vhost/tcm_vhost.c
rename to drivers/vhost/scsi.c
-- 
MST
