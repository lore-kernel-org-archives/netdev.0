From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv6] virtio-spec: virtio network device multiqueue support
Date: Mon, 10 Dec 2012 12:36:07 +0200
Message-ID: <20121210103606.GA26168@redhat.com>
References: <20121207141856.GA17901@redhat.com>
 <87ip8aeqi7.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	kvm@vger.kernel.org, bhutchings@solarflare.com
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18858 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209Ab2LJKdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2012 05:33:02 -0500
Content-Disposition: inline
In-Reply-To: <87ip8aeqi7.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 10, 2012 at 10:18:32AM +1030, Rusty Russell wrote:
> "Michael S. Tsirkin" <mst@redhat.com> writes:
> > Add multiqueue support to virtio network device.
> > Add a new feature flag VIRTIO_NET_F_MQ for this feature, a new
> > configuration field max_virtqueue_pairs to detect supported number of
> > virtqueues as well as a new command VIRTIO_NET_CTRL_MQ to program
> > packet steering for unidirectional protocols.
> 
> One trivial change: alter "8000h" to "0x8000" for consistency in the
> text.
> 
> Could I have a Signed-off-by so I can apply it please?
> 
> Thanks,
> Rusty.

Right away.

-- 
MST
