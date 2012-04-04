From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V6 PATCH] virtio-net: send gratuitous packets when needed
Date: Wed, 4 Apr 2012 10:51:37 +0300
Message-ID: <20120404075137.GB22658@redhat.com>
References: <20120328054428.34415.75432.stgit@amd-6168-8-1.englab.nay.redhat.com>
	<20120403.174905.769295608759578804.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20120403.174905.769295608759578804.davem@davemloft.net>
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

On Tue, Apr 03, 2012 at 05:49:05PM -0400, David Miller wrote:
> From: Jason Wang <jasowang@redhat.com>
> Date: Wed, 28 Mar 2012 13:44:28 +0800
> 
> > As hypervior does not have the knowledge of guest network configuration, it's
> > better to ask guest to send gratuitous packets when needed.
> > 
> > Guest tests VIRTIO_NET_S_ANNOUNCE bit during config change interrupt and when it
> > is set, a workqueue is scheduled to send gratuitous packet through
> > NETDEV_NOTIFY_PEERS. This feature is negotiated through bit
> > VIRTIO_NET_F_GUEST_ANNOUNCE.
>  ...
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Michael and others, what's the story with this patch?

It's a new feature so it will be 3.5 material when it's ready.
Sent some comments for now.

Thanks,
MST


> _______________________________________________
> Virtualization mailing list
> Virtualization@lists.linux-foundation.org
> https://lists.linuxfoundation.org/mailman/listinfo/virtualization
