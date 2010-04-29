From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: linux-next: manual merge of the rr tree with the net tree
Date: Thu, 29 Apr 2010 22:23:36 +0930
Message-ID: <201004292223.36270.rusty@rustcorp.com.au>
References: <20100427115852.9f4cbb0f.sfr@canb.auug.org.au> <20100427040913.GA19951@redhat.com> <20100428155457.GB7467@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100428155457.GB7467@redhat.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 29 Apr 2010 01:24:57 am Michael S. Tsirkin wrote:
> On Tue, Apr 27, 2010 at 07:09:13AM +0300, Michael S. Tsirkin wrote:
> > On Tue, Apr 27, 2010 at 11:58:52AM +1000, Stephen Rothwell wrote:
> > > Hi Rusty,
> > > 
> > > Today's linux-next merge of the rr tree got a conflict in
> > > drivers/net/virtio_net.c between commit
> > > 5e01d2f91df62be4d6f282149bc2a8858992ceca ("virtio-net: move sg off
> > > stack") from the net tree and commit
> > > 7f62a724a65f864d84f50857bbfd36c240155c8f ("virtio_net: use virtqueue_xxx
> > > wrappers") from the rr tree.
> > > 
> > > I fixed it up (see below) and can carry the fix as necessary.
> > 
> > Hmm, Rusty, do you intend for the patches to go through netdev this
> > time? If you do, it might be simplest to just ask Dave to merge
> > them in net-next-2.6 now. I can prepare and send them if you like.

Naah, they hit too many random virtio drivers.  It's pretty simple to keep
them separate, and once the new API is in place I'll send to Dave to merge.
It could take two cycles, but there's no huge rush.

Cheers,
Rusty.
