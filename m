From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net/virtio_ring: fix race in enable_cb
Date: Mon, 17 Mar 2008 23:10:52 +1100
Message-ID: <200803172310.52460.rusty@rustcorp.com.au>
References: <200803141417.05696.borntraeger@de.ibm.com> <200803171248.14570.rusty@rustcorp.com.au> <200803170730.44218.borntraeger@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org
To: Christian Borntraeger <borntraeger@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:59177 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753164AbYCQMNz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:13:55 -0400
In-Reply-To: <200803170730.44218.borntraeger@de.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 17 March 2008 17:30:44 Christian Borntraeger wrote:
> > Are you seeing the "Unlikely: restart svq failed" message in the logs? 
> > If not, I don't think it can be this race.
>
> No, I dont see the message, but this message only happens for guest->host
> traffic in the xmit function.

Interesting you don't see this.  Or is it just on that load that you don't see 
it?

> I was fixing the poll function - which has no 
> printk.
> I added the disable_cb in the xmit function only  to adopt to changed
> enable_cb semantics.
>
> I double checked my theory with a printk in enable_cb. The more_used check
> was true several times for the receiving virtqueue.

Excellent, thanks.

I applied your patch, and have asked Linus to pull that and my other qeued 
virtio fixes.

Cheers,
Rusty.
