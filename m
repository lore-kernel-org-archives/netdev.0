From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: RDMA will be reverted
Date: Fri, 7 Jul 2006 10:03:37 +1000
Message-ID: <20060707000337.GA31273@gondor.apana.org.au>
References: <E1FyUX2-0007Gm-00@gondolin.me.apana.org.au> <1152207384.20248.104.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, rdreier@cisco.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4359 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750881AbWGGAET
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jul 2006 20:04:19 -0400
To: Tom Tucker <tom@opengridcomputing.com>
Content-Disposition: inline
In-Reply-To: <1152207384.20248.104.camel@trinity.ogc.int>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 06, 2006 at 12:36:24PM -0500, Tom Tucker wrote:
> 
> The RDMA CMA uses IP addresses and port numbers to create a uniform
> addressing scheme across all transport types. For IB, it is necessary to
> resolve IP addresses to IB GIDs. The ARP protocol is used to do this and
> a netfilter rule is installed to snoop the incoming ARP replies. This
> would not be necessary if ARP events were provided as in the patch. 

Well the concerns we have do not apply to just iWARP, but RDMA/IP in
general so this isn't really another technology.

In fact, it seems that we now have IP-specific knowledge living in
drivers/infiniband/core/cma.c which is suboptimal.

> Unified wire iSCSI adapters have the same issue as iWARP wrt to managing
> IP addresses and ports.

If by Unified wire iSCSI you mean something that presents a SCSI interface
together with an Ethernet interface where the two share the same MAC and
IP address, then we have the same concerns with it as we do with iWARP or
TOE.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
