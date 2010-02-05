From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Thu, 04 Feb 2010 17:02:10 -0800
Message-ID: <1265331730.31059.22.camel@w-sridhar.beaverton.ibm.com>
References: <1265239340.5600.21.camel@w-sridhar.beaverton.ibm.com>
	 <20100205005256.GA9969@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:52434 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754892Ab0BEBCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 20:02:17 -0500
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e38.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o150unHg024354
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 17:56:49 -0700
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o1512CgX088900
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:02:12 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o1512BKe016671
	for <netdev@vger.kernel.org>; Thu, 4 Feb 2010 18:02:11 -0700
In-Reply-To: <20100205005256.GA9969@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-02-05 at 11:52 +1100, Herbert Xu wrote:
> On Wed, Feb 03, 2010 at 03:22:20PM -0800, Sridhar Samudrala wrote:
> >
> > -	skb_reserve(skb, LL_RESERVED_SPACE(dev));
> > -	skb_reset_network_header(skb);
> > +	skb_set_network_header(skb, reserve);
> 
> Is this going to produce the right network header for the SOCK_DGRAM
> case?	

In the case of SOCK_DGRAM reserve is not set and will be 0 and hence
it is same as calling skb_reset_network_header(skb)

Thanks
Sridhar

