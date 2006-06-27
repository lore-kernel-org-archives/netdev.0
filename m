From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH REPOST 0/2][RFC] Network Event Notifier Mechanism
Date: Tue, 27 Jun 2006 22:50:33 +1000
Message-ID: <E1FvD1V-00043F-00@gondolin.me.apana.org.au>
References: <20060623201918.32482.89765.stgit@stevo-desktop>
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16403 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932223AbWF0Muz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 08:50:55 -0400
To: swise@opengridcomputing.com (Steve Wise)
In-Reply-To: <20060623201918.32482.89765.stgit@stevo-desktop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise <swise@opengridcomputing.com> wrote:
> 
> This patch implements a mechanism that allows interested clients to
> register for notification of certain network events. The intended use
> is to allow RDMA devices (linux/drivers/infiniband) to be notified of
> neighbour updates, ICMP redirects, path MTU changes, and route changes.
> 
> The reason these devices need update events is because they typically
> cache this information in hardware and need to be notified when this
> information has been updated.
> 
> The key events of interest are:
> 
> - neighbour mac address change 
> - routing redirect (the next hop neighbour changes for a dst_entry)
> - path mtu change (the patch mtu for a dst_entry changes).
> - route add/deletes

I'd like to know more about what the RDMA device is going to do with this
information.  I thought RDMA was for receiving packets? Most of the info
here pertains to transmission.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
