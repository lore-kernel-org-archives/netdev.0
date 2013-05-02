From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/3] vhost-scsi: file renames
Date: Thu, 2 May 2013 04:45:30 +0300
Message-ID: <cover.1367459045.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	Stefan Hajnoczi <stefanha@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
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

This reorgs the files a bit, renaming tcm_vhost to
vhost_scsi as that's how userspace refers to it.
While at it, cleanup some leftovers from when it was a
staging driver.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>


Michael S. Tsirkin (3):
  vhost: src file renames
  tcm_vhost: header split up
  vhost_scsi: module rename

 drivers/vhost/Kconfig                 |  10 ++-
 drivers/vhost/Kconfig.tcm             |   6 --
 drivers/vhost/Makefile                |   3 +-
 drivers/vhost/{tcm_vhost.c => scsi.c} | 115 ++++++++++++++++++++++++++---
 drivers/vhost/tcm_vhost.h             | 131 ----------------------------------
 include/uapi/linux/vhost.h            |  28 ++++++++
 6 files changed, 143 insertions(+), 150 deletions(-)
 delete mode 100644 drivers/vhost/Kconfig.tcm
 rename drivers/vhost/{tcm_vhost.c => scsi.c} (94%)
 delete mode 100644 drivers/vhost/tcm_vhost.h

-- 
MST
