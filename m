From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] xfrm: Don't queue retransmitted packets if the
 original is still on the host
Date: Fri, 18 Oct 2013 16:19:08 -0400 (EDT)
Message-ID: <20131018.161908.1422032342884472542.davem@davemloft.net>
References: <1381881514.2045.82.camel@edumazet-glaptop.roam.corp.google.com>
	<20131016094549.GZ7660@secunet.com>
	<20131016114246.GB7660@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58123 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013Ab3JRUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 16:19:10 -0400
In-Reply-To: <20131016114246.GB7660@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 16 Oct 2013 13:42:47 +0200

> It does not make sense to queue retransmitted packets if the
> original packet is still in some queue of this host. So add
> a check to xdst_queue_output() and drop the packet if the
> original packet is not yet sent.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

I have no problems with this, what about you Eric?
