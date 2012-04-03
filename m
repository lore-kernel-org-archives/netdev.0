From: David Miller <davem@davemloft.net>
Subject: Re: [V6 PATCH] virtio-net: send gratuitous packets when needed
Date: Tue, 03 Apr 2012 17:49:05 -0400 (EDT)
Message-ID: <20120403.174905.769295608759578804.davem@davemloft.net>
References: <20120328054428.34415.75432.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org
To: jasowang@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20120328054428.34415.75432.stgit@amd-6168-8-1.englab.nay.redhat.com>
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
Date: Wed, 28 Mar 2012 13:44:28 +0800

> As hypervior does not have the knowledge of guest network configuration, it's
> better to ask guest to send gratuitous packets when needed.
> 
> Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt and when it
> is set, a workqueue is scheduled to send gratuitous packet through
> NETDEV_NOTIFY_PEERS. This feature is negotiated through bit
> VIRTIO_NET_F_GUEST_ANNOUNCE.
 ...
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Michael and others, what's the story with this patch?
