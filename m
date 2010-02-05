From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next-2.6] packet: Add GSO/csum offload support.
Date: Thu, 04 Feb 2010 20:25:28 -0800 (PST)
Message-ID: <20100204.202528.69423500.davem@davemloft.net>
References: <20100205005256.GA9969@gondor.apana.org.au>
	<1265331730.31059.22.camel@w-sridhar.beaverton.ibm.com>
	<20100205021406.GA10651@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sri@us.ibm.com, mst@redhat.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45258
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753513Ab0BEEZP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2010 23:25:15 -0500
In-Reply-To: <20100205021406.GA10651@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 5 Feb 2010 13:14:06 +1100

> On Thu, Feb 04, 2010 at 05:02:10PM -0800, Sridhar Samudrala wrote:
>> 
>> In the case of SOCK_DGRAM reserve is not set and will be 0 and hence
>> it is same as calling skb_reset_network_header(skb)
> 
> Thanks for the explanation.  The patch looks good to me.

Patch applied, thanks everyone.

Sridhar, your patch had several cases of trailing whitespace which I
fixed up when applying.  Because tools are able to find such errors in
an automated way, these kinds of things should never show up in a
patch submission.  Please fix such things up before submitting patches
in the future.

Thanks again.
