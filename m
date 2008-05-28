From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 2/3] virtio: fix delayed xmit of packet and freeing of old packets.
Date: Wed, 28 May 2008 14:59:09 +1000
Message-ID: <200805281459.09564.rusty@rustcorp.com.au>
References: <200805261742.43215.rusty@rustcorp.com.au> <200805261748.13449.rusty@rustcorp.com.au> <1211886068.3637.42.camel@muff>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:54378 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751484AbYE1E7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 May 2008 00:59:25 -0400
In-Reply-To: <1211886068.3637.42.camel@muff>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 27 May 2008 21:01:08 Mark McLoughlin wrote:
> On Mon, 2008-05-26 at 17:48 +1000, Rusty Russell wrote:
> > diff -r 1d1ff03de434 drivers/net/virtio_net.c
> ...
> > +	tasklet_init(&vi->tasklet, xmit_tasklet, (unsigned long)vi);
> > +
> >  	err = register_netdev(dev);
>
> Missing a tasklet_kill() in virtnet_remove() ?

Thanks Mark!  Added.

Nice spotting,
Rusty.
