From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH v2 00/10] ftgmac100: Rework batch 4 - Misc
Date: Thu, 13 Apr 2017 07:32:01 +1000
Message-ID: <1492032721.7236.68.camel@kernel.crashing.org>
References: <20170412032710.17546-1-benh@kernel.crashing.org>
         <20170412.101934.2165788638655556260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:50992 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751090AbdDLVdN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 17:33:13 -0400
In-Reply-To: <20170412.101934.2165788638655556260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-04-12 at 10:19 -0400, David Miller wrote:
> 
> > v2 Fixes patch 1/10 (NETIF_F_HW_CSUM conversion)
> > 
> > The next (and last) batch will add a few more "features" such
> > as netpoll, multicast/promist, vlan offload...
> > 
> 
> Series applied, thanks Benjamin.
> 
> I really like how you use the reset task to implement ring resizing.

Thanks :-)

I didn't see the point of doing it synchronously as it's not "urgent"
and this keeps the code a lot simpler.

Cheers,
Ben.
