From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 0/2] adding tracepoints to vhost
Date: Tue, 10 Apr 2012 10:58:10 +0800
Message-ID: <20120410025327.49693.93562.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, kvm@vger.kernel.org, mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
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

To help in vhost analyzing, the following series adding basic tracepoints to
vhost. Operations of both virtqueues and vhost works were traced in current
implementation, net code were untouched. A top-like satistics displaying script
were introduced to help the troubleshooting.

TODO:
- net specific tracepoints?

---

Jason Wang (2):
      vhost: basic tracepoints
      tools: virtio: add a top-like utility for displaying vhost satistics


 drivers/vhost/trace.h   |  153 ++++++++++++++++++++
 drivers/vhost/vhost.c   |   17 ++
 tools/virtio/vhost_stat |  360 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 528 insertions(+), 2 deletions(-)
 create mode 100644 drivers/vhost/trace.h
 create mode 100755 tools/virtio/vhost_stat

-- 
Jason Wang
