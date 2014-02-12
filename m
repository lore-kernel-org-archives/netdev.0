From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH net 0/3] vhost fixes for 3.14, -stable
Date: Wed, 12 Feb 2014 18:37:55 +0200
Message-ID: <1392222846-26699-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: virtio-dev@lists.oasis-open.org, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org, qinchuanyu@huawei.com,
	davem@davemloft.net
To: linux-kernel@vger.kernel.org
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

This fixes a deadlock with vhost reported in the field,
as well as a theoretical race issue found by code
review.

Patches 1+2 are needed for stable.

Thanks to Qin Chuanyu for reporting the issue!

Michael S. Tsirkin (3):
  kref: add kref_sub_return
  vhost: fix ref cnt checking deadlock
  vhost: fix a theoretical race in device cleanup

 include/linux/kref.h | 33 ++++++++++++++++++++++++++++++++-
 drivers/vhost/net.c  | 15 ++++++++++-----
 2 files changed, 42 insertions(+), 6 deletions(-)

-- 
MST
