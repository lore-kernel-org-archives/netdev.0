From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio-net: pass gfp to add_buf
Date: Tue, 1 Jun 2010 16:58:54 +0930
Message-ID: <201006011658.55605.rusty@rustcorp.com.au>
References: <201005312040.01737.rusty@rustcorp.com.au> <20100601.002246.149820849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:41731 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752557Ab0FAH27 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Jun 2010 03:28:59 -0400
In-Reply-To: <20100601.002246.149820849.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 1 Jun 2010 04:52:46 pm David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Mon, 31 May 2010 20:40:01 +0930
> 
> > From: "Michael S. Tsirkin" <mst@redhat.com>
> > 
> > (Dave: the virtqueue_add_buf_gfp is in Linus' tree, so please queue
> >  this trivial use now.  Thanks!)
> > 
> > virtio-net bounces buffer allocations off to
> > a thread if it can't allocate buffers from the atomic
> > pool. However, if posting buffers still requires atomic
> > buffers, this is unlikely to succeed.
> > Fix by passing in the proper gfp_t parameter.
> > 
> > Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> Your code sucks, and you're wrong.
> 
> Please give me positive feedback and tell me how right I am to pump up
> my ego or else I will verbally destroy you and make you feel small.
> 
> Applied :-)))))))))))))))

Thanks Dave, that made my day :)

Cheers,
Rusty.
