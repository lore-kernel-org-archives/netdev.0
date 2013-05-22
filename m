From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: possible bug in IPv6 MLD retransmissions
Date: Wed, 22 May 2013 14:51:21 +0200
Message-ID: <20130522125120.GF32093@order.stressinduktion.org>
References: <20130517032449.GA3595@obelix.rh> <20130518173105.GD29528@order.stressinduktion.org> <20130521150616.GA8513@obelix.rh> <20130522004027.GD32093@order.stressinduktion.org> <OF1A7F184A.4282AFE8-ON85257B73.003E82A8-85257B73.003F3B88@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:54873 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705Ab3EVMvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 08:51:22 -0400
Content-Disposition: inline
In-Reply-To: <OF1A7F184A.4282AFE8-ON85257B73.003E82A8-85257B73.003F3B88@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 22, 2013 at 07:30:39AM -0400, David Stevens wrote:
> First, I wouldn't call this a "bug"; it is listed as a "SHOULD", not a 
> "MUST",  so
> it is not required for compliance, though it is a good feature to add.

Ok.

> Second, I think doing this on all LL addresses unconditionally isn't a 
> good
> idea. If some configuration is using thousands of LL addrs for reasons of 
> their
> own, they would suddenly be blasted with unexpected MLD reports where
> they have none now. I don't see why tracking it would be such a problem --
> if nothing else, you could simply add a counter for the number of valid LL 
> addrs
> incremented on DAD completion, and send these whenever it transitions from 
> 0 to 1.

I understand your concerns and will revisit the patch and check if a
dad_completed_counter would simplify the code.

Thanks,

  Hannes
