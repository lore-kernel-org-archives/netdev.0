From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [V2 PATCH 0/9] vhost/macvtap zeropcopy fixes
Date: Wed, 2 May 2012 08:50:09 +0300
Message-ID: <20120502055008.GA29319@redhat.com>
References: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebiederm@xmission.com,
	davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120502033901.11782.13157.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 02, 2012 at 11:41:21AM +0800, Jason Wang wrote:
> This is an updated since the last series of vhost/macvtap zerocopy fixes which
> fixes the the possible transmission stall, host kernel stack overflow and other
> misc fixes.
> 
> Changes from V1:
> - Addressing comments from Eric and Michael.
> - Adding more fixes into the seires.

Thanks for fixing this.
Acked-by: Michael S. Tsirkin <mst@redhat.com>

Dave, can you merge this for 3.4 please?
Thanks!

> ---
> 
> Jason Wang (9):
>       macvtap: zerocopy: fix offset calculation when building skb
>       macvtap: zerocopy: fix truesize underestimation
>       macvtap: zerocopy: put page when fail to get all requested user pages
>       macvtap: zerocopy: set SKBTX_DEV_ZEROCOPY only when skb is built successfully
>       macvtap: zerocopy: validate vectors before building skb
>       vhost_net: zerocopy: fix possible NULL pointer dereference of vq->bufs
>       vhost_net: re-poll only on EAGAIN or ENOBUFS
>       vhost_net: zerocopy: adding and signalling immediately when fully copied
>       vhost: zerocopy: poll vq in zerocopy callback
> 
> 
>  drivers/net/macvtap.c |   57 ++++++++++++++++++++++++++++++++++---------------
>  drivers/vhost/net.c   |    7 ++++--
>  drivers/vhost/vhost.c |    1 +
>  3 files changed, 46 insertions(+), 19 deletions(-)
> 
> -- 
> Jason Wang
