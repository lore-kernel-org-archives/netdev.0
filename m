From: David Miller <davem@davemloft.net>
Subject: Re: Generic TSO
Date: Fri, 11 Mar 2016 15:22:26 -0500 (EST)
Message-ID: <20160311.152226.364781080223352858.davem@davemloft.net>
References: <CAEh+42hEVQOFaFk7BW=wZ-gb9HCfYqbr7Q600gbm1q1Oz+yZcA@mail.gmail.com>
	<CALx6S36EyzjWKi_iK_uAVcCceFnZe3QmLcw7BBejKuB79Uo7PA@mail.gmail.com>
	<56E31A89.9020602@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbcCKUW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 15:22:29 -0500
In-Reply-To: <56E31A89.9020602@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Fri, 11 Mar 2016 19:20:41 +0000

> Are you planning to / working on implementing this?  If not, I might have a
> crack at it; I've talked to our firmware guys and (provisionally) we think
> we can support it in current sfc hardware.
> Or were there any blocking problems raised in the thread?  My understanding
> of the IP ID issue was that it only matters for the inner frame, because
> the rest aren't TCP (so hopefully no-one is doing SLHC on them).  But I may
> have missed something.

I've thought a lot more about the IP ID issue, and I am now starting
to learn towards allowing it to be set to zero for "DF" packets.

Considering what we gain in return, not working optimally with an
ancient SLIP header compression implementation is a small loss.

Any other opinions?
