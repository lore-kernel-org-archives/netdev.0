From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net-next V5 0/9] vhost_net rx batch dequeuing
Date: Fri, 19 May 2017 19:36:49 +0300
Message-ID: <20170519193636-mutt-send-email-mst@kernel.org>
References: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
 <20170517235738-mutt-send-email-mst@kernel.org>
 <0d1dbf31-32c8-34b4-d8e8-48d04f2fc205@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0d1dbf31-32c8-34b4-d8e8-48d04f2fc205@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 19, 2017 at 02:27:16PM +0800, Jason Wang wrote:
> 
> 
> On 2017年05月18日 04:59, Michael S. Tsirkin wrote:
> > On Wed, May 17, 2017 at 12:14:36PM +0800, Jason Wang wrote:
> > > This series tries to implement rx batching for vhost-net. This is done
> > > by batching the dequeuing from skb_array which was exported by
> > > underlayer socket and pass the sbk back through msg_control to finish
> > > userspace copying. This is also the requirement for more batching
> > > implemention on rx path.
> > > 
> > > Tests shows at most 7.56% improvment bon rx pps on top of batch
> > > zeroing and no obvious changes for TCP_STREAM/TCP_RR result.
> > > 
> > > Please review.
> > > 
> > > Thanks
> > A surprisingly large gain for such as simple change.  It would be nice
> > to understand better why this helps - in particular, does the optimal
> > batch size change if ring is bigger or smaller?
> 
> Will test, just want to confirm. You mean virtio ring not tx_queue_len here?
> 
> Thanks

Exactly.
Thanks,
MST
