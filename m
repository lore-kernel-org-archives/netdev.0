From: Greg Kurz <gkurz@linux.vnet.ibm.com>
Subject: [PATCH 0/2] vhost: cross-endian code cleanup
Date: Wed, 13 Jan 2016 18:09:34 +0100
Message-ID: <20160113170934.23705.62626.stgit@bahia.huguette.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
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

This series is a respin of the following patch:

http://patchwork.ozlabs.org/patch/565921/

Patch 1 is preliminary work: it gives better names to the helpers that are
involved in cross-endian support.

Patch 2 is actually a v2 of the original patch. All devices now call a
helper in the generic code, which DTRT according to vq->private_data, as
suggested by Michael.

---

Greg Kurz (2):
      vhost: helpers to enable/disable vring endianness
      vhost: disentangle vring endianness stuff from the core code


 drivers/vhost/net.c   |    3 +++
 drivers/vhost/scsi.c  |    3 +++
 drivers/vhost/test.c  |    2 ++
 drivers/vhost/vhost.c |   40 ++++++++++++++++++++++++++++------------
 drivers/vhost/vhost.h |    1 +
 5 files changed, 37 insertions(+), 12 deletions(-)
