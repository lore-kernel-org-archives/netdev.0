From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 0/3] virtio and vhost-net performance enhancements
Date: Thu, 5 May 2011 18:07:56 +0300
Message-ID: <cover.1304605816.git.mst@redhat.com>
References: <cover.1304541918.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Carsten Otte <cotte@de.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	linux390@de.ibm.com, Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Shirley Ma <xma@us.ibm.com>, lguest@lists.ozlabs.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, kvm@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Tom Lendacky <tahm@linux.vnet.ibm.com>, steved@us.ibm.com,
	habanero@linux.vnet.ibm.com
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1304541918.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here are a couple of minor fixes suggested on list.
Applies on top of the previous patchset.

As before result pushed here:
git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git vhost-net-next-event-idx-v1

Michael S. Tsirkin (3):
  virtio: fix avail event support
  virtio_ring: check used_event offset
  virtio_ring: need_event api comment fix

 drivers/virtio/virtio_ring.c |    2 +-
 include/linux/virtio_ring.h  |   10 ++++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)

-- 
1.7.5.53.gc233e
