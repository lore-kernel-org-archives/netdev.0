From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] virtio_net: fix oom handling on tx
Date: Fri, 02 Jul 2010 22:29:51 -0700 (PDT)
Message-ID: <20100702.222951.260082920.davem@davemloft.net>
References: <201007031232.56510.rusty@rustcorp.com.au>
	<201007031234.01937.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, herbert@gondor.apana.org.au
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57374
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753318Ab0GCF3l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jul 2010 01:29:41 -0400
In-Reply-To: <201007031234.01937.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Sat, 3 Jul 2010 12:34:01 +1000

> virtio net will never try to overflow the TX ring, so the only reason
> add_buf may fail is out of memory. Thus, we can not stop the
> device until some request completes - there's no guarantee anything
> at all is outstanding.
> 
> Make the error message clearer as well: error here does not
> indicate queue full.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au> (...and avoid TX_BUSY)
> Cc: stable@kernel.org  # .34.x (s/virtqueue_/vi->svq->vq_ops->/)

Applied.
