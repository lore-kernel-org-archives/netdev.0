From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Thu, 17 Mar 2011 08:10:05 -0700
Message-ID: <1300374605.3255.43.camel@localhost.localdomain>
References: <1300320775.3255.34.camel@localhost.localdomain>
	 <874o72gwm5.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>, kvm@vger.kernel.org,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:43431 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab1CQPKT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 11:10:19 -0400
In-Reply-To: <874o72gwm5.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-03-17 at 15:40 +1030, Rusty Russell wrote:
> This is fascinating... and deeply weird.
> 
> OK, what's the difference between calling xmit_skb and ignoring
> failure,
> and this patch which figures out it's going to fail before calling
> xmit_skb?
> 
> ie. what if you *just* delete this:

Somehow what was in my mind, add_buf is more expensive than simply
checked ring capacity. I retest it with your and Michael's suggestion
here.

Thanks
Shirley

