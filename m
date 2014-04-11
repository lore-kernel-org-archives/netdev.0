From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Thu, 10 Apr 2014 21:40:23 -0400 (EDT)
Message-ID: <20140410.214023.849284639345029049.davem@davemloft.net>
References: <20140407142334.GA28814@gondor.apana.org.au>
	<53442868.3090701@candelatech.com>
	<20140408172349.GA7147@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbaDKBk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Apr 2014 21:40:27 -0400
In-Reply-To: <20140408172349.GA7147@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 9 Apr 2014 01:23:49 +0800

> On Tue, Apr 08, 2014 at 09:48:40AM -0700, Ben Greear wrote:
>> 
>> At least for ARPs, maybe we could inspect the packet and only
>> deliver to interfaces configured with the MAC that is being
>> ARPed for (or ones that are in promisc)?
> 
> Yes this would definitely be a great optimisation.

Yes and you can use the direct rather than the workqueue path.
