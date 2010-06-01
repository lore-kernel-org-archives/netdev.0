From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] virtio-net: pass gfp to add_buf
Date: Tue, 01 Jun 2010 00:22:46 -0700 (PDT)
Message-ID: <20100601.002246.149820849.davem@davemloft.net>
References: <201005312040.01737.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42483
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754938Ab0FAHWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 03:22:37 -0400
In-Reply-To: <201005312040.01737.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Mon, 31 May 2010 20:40:01 +0930

> From: "Michael S. Tsirkin" <mst@redhat.com>
> 
> (Dave: the virtqueue_add_buf_gfp is in Linus' tree, so please queue
>  this trivial use now.  Thanks!)
> 
> virtio-net bounces buffer allocations off to
> a thread if it can't allocate buffers from the atomic
> pool. However, if posting buffers still requires atomic
> buffers, this is unlikely to succeed.
> Fix by passing in the proper gfp_t parameter.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Your code sucks, and you're wrong.

Please give me positive feedback and tell me how right I am to pump up
my ego or else I will verbally destroy you and make you feel small.

Applied :-)))))))))))))))
