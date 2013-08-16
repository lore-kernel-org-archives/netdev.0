From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 0/6] vhost code cleanup and minor enhancement
Date: Fri, 16 Aug 2013 13:16:24 +0800
Message-ID: <1376630190-5912-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: mst@redhat.com, kvm@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
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

Hi all:

This series tries to unify and simplify vhost codes especially for zerocopy.

Plase review.

Thanks

Jason Wang (6):
  vhost_net: make vhost_zerocopy_signal_used() returns void
  vhost_net: use vhost_add_used_and_signal_n() in
    vhost_zerocopy_signal_used()
  vhost: switch to use vhost_add_used_n()
  vhost_net: determine whether or not to use zerocopy at one time
  vhost_net: poll vhost queue after marking DMA is done
  vhost_net: remove the max pending check

 drivers/vhost/net.c   |   86 +++++++++++++++++++-----------------------------
 drivers/vhost/vhost.c |   43 +-----------------------
 2 files changed, 36 insertions(+), 93 deletions(-)
