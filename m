From: Aaron Conole <aconole@redhat.com>
Subject: [PATCH -next 0/2] virtio-net: Advised MTU feature
Date: Thu,  2 Jun 2016 11:43:29 -0400
Message-ID: <1464882211-18723-1-git-send-email-aconole@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>
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
  virtio: Start feature MTU support
  virtio_net: Read the advised MTU

 drivers/net/virtio_net.c        | 7 +++++++
 include/uapi/linux/virtio_net.h | 2 ++
 2 files changed, 9 insertions(+)

-- 
2.5.5
