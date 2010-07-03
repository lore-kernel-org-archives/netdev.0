From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] virtio_net: do not reschedule rx refill forever
Date: Fri, 02 Jul 2010 22:29:45 -0700 (PDT)
Message-ID: <20100702.222945.48498211.davem@davemloft.net>
References: <201007031232.56510.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57367
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753102Ab0GCF3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 01:29:32 -0400
In-Reply-To: <201007031232.56510.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 3 Jul 2010 12:32:55 +1000

> From: "Michael S. Tsirkin" <mst@redhat.com>
> 
> We currently fill all of RX ring, then add_buf
> returns ENOSPC, which gets mis-detected as an out of
> memory condition and causes us to reschedule the work,
> and so on forever. Fix this by oom = err == -ENOMEM;
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Cc: stable@kernel.org # .34.x

Applied.
