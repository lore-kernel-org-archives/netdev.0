From: David Miller <davem@davemloft.net>
Subject: Re: [V5 PATCH] virtio-net: send gratuitous packets when needed
Date: Tue, 27 Mar 2012 22:31:12 -0400 (EDT)
Message-ID: <20120327.223112.2032989102915830685.davem@davemloft.net>
References: <20120316090100.5223.50783.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120316090100.5223.50783.stgit@amd-6168-8-1.englab.nay.redhat.com>
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

From: Jason Wang <jasowang@redhat.com>
Date: Fri, 16 Mar 2012 17:01:01 +0800

> As hypervior does not have the knowledge of guest network configuration, it's
> better to ask guest to send gratuitous packets when needed.
> 
> Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt and when it
> is set, a workqueue is scheduled to send gratuitous packet through
> NETDEV_NOTIFY_PEERS. This feature is negotiated through bit
> VIRTIO_NET_F_GUEST_ANNOUNCE.
> 
> Changes from v4:
> - typos
> - handle workqueue unconditionally
> - move VIRTIO_NET_S_ANNOUNCE to bit 8 to separate rw bits from ro bits
> 
> Changes from v3:
> - cancel the workqueue during freeze
> 
> Changes from v2:
> - fix the race between unregister_dev() and workqueue
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

What's happening with this patch?
