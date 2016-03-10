From: Aaron Conole <aconole@redhat.com>
Subject: [RFC -next 0/2] virtio-net: Advised MTU feature
Date: Thu, 10 Mar 2016 09:28:10 -0500
Message-ID: <1457620092-24170-1-git-send-email-aconole@redhat.com>
To: netdev@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	virtualization@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following series adds the ability for a hypervisor to set an MTU on the
guest during feature negotiation phase. This is useful for VM orchestration
when, for instance, tunneling is involved and the MTU of the various systems
should be homogenous.

The first patch adds the feature bit as described in the proposed VFIO spec
addition found at
https://lists.oasis-open.org/archives/virtio-dev/201603/msg00001.html

The second patch adds a user of the bit, and a warning when the guest changes
the MTU from the hypervisor advised MTU. Future patches may add more thorough
error handling.

Aaron Conole (2):
  virtio: Start the advised MTU feature support
  virtio_net: Read and use the advised MTU

 drivers/net/virtio_net.c        | 15 ++++++++++++++-
 include/uapi/linux/virtio_net.h |  3 +++
 2 files changed, 17 insertions(+), 1 deletion(-)

-- 
2.5.0
