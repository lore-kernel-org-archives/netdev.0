From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RESEND PATCH] virtio-net: init link state correctly
Date: Wed, 10 Nov 2010 17:08:23 +0200
Message-ID: <20101110150823.GA5622@redhat.com>
References: <20101105094718.19101.58898.stgit@dhcp-91-158.nay.redhat.com>
 <201011080941.28190.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	markmc@redhat.com, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756489Ab0KJPIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 10:08:36 -0500
Content-Disposition: inline
In-Reply-To: <201011080941.28190.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 08, 2010 at 09:41:27AM +1030, Rusty Russell wrote:
> On Fri, 5 Nov 2010 08:17:18 pm Jason Wang wrote:
> > For device that supports VIRTIO_NET_F_STATUS, there's no need to
> > assume the link is up and we need to call nerif_carrier_off() before
> > querying device status, otherwise we may get wrong operstate after
> > diver was loaded because the link watch event was not fired as
> > expected.
> > 
> > For device that does not support VIRITO_NET_F_STATUS, we could not get
> > its status through virtnet_update_status() and what we can only do is
> > always assuming the link is up.
> > 
> > Acked-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> Acked-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Thanks!
> Rusty.

Rusty, just to verify: who shall be queueing this up?
