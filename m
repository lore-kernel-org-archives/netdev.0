From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: RDMA will be reverted
Date: Thu, 06 Jul 2006 12:36:24 -0500
Message-ID: <1152207384.20248.104.camel@trinity.ogc.int>
References: <E1FyUX2-0007Gm-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rdreier@cisco.com, netdev@vger.kernel.org,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from es335.com ([67.65.19.105]:54870 "EHLO mail.es335.com")
	by vger.kernel.org with ESMTP id S1030336AbWGFRg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jul 2006 13:36:28 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1FyUX2-0007Gm-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-07-07 at 00:08 +1000, Herbert Xu wrote:
> Tom Tucker <tom@opengridcomputing.com> wrote:
> > 
> > All that said, the proposed patch helps not only iWARP, but other
> > transports (iSCSI, IB) as well. It is not large, invasive,
> 
> Care to explain on how it helps those other technologies?

The RDMA CMA uses IP addresses and port numbers to create a uniform
addressing scheme across all transport types. For IB, it is necessary to
resolve IP addresses to IB GIDs. The ARP protocol is used to do this and
a netfilter rule is installed to snoop the incoming ARP replies. This
would not be necessary if ARP events were provided as in the patch. 

Unified wire iSCSI adapters have the same issue as iWARP wrt to managing
IP addresses and ports.


> 
> Cheers,

