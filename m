From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] vhost-net: switch to smp barriers
Date: Mon, 8 Feb 2010 18:49:39 +1030
Message-ID: <201002081849.39512.rusty@rustcorp.com.au>
References: <20100201172101.GA10900@redhat.com> <20100207090749.GA12968@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38592 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754332Ab0BHITo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 03:19:44 -0500
In-Reply-To: <20100207090749.GA12968@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 7 Feb 2010 07:37:49 pm Michael S. Tsirkin wrote:
> On Mon, Feb 01, 2010 at 07:21:02PM +0200, Michael S. Tsirkin wrote:
> > vhost-net only uses memory barriers to control SMP effects
> > (communication with userspace potentially running on a different CPU),
> > so it should use SMP barriers and not mandatory barriers for memory
> > access ordering, as suggested by Documentation/memory-barriers.txt
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> 
> 
> Rusty, any feedback on this one?
> Thanks!

Yep.  barrier() is correct on UP to guard against preemption.

Acked-by: Rusty Russell <rusty@rustcorp.com.au>

Thanks,
Rusty.
