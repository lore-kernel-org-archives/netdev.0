From: David Miller <davem@davemloft.net>
Subject: Re: RDMA will be reverted
Date: Tue, 25 Jul 2006 00:33:44 -0700 (PDT)
Message-ID: <20060725.003344.125313848.davem@davemloft.net>
References: <20060725055127.GA5103@2ka.mipt.ru>
	<20060724.234853.112197982.davem@davemloft.net>
	<20060725065921.GB30561@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier@cisco.com, ak@suse.de, tom@opengridcomputing.com,
	netdev@vger.kernel.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:27051
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751305AbWGYHds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 03:33:48 -0400
To: johnpol@2ka.mipt.ru
In-Reply-To: <20060725065921.GB30561@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 25 Jul 2006 10:59:21 +0400

> As a side completely unrelated to either my or others work note :) - 
> I think it is a nanooptimisation - we get a bit of performance here, 
> and lose those bit in other place.
> When bag is filled, there is no much sence of rearranging some stuff
> inside to be able to place another one - it is better to buy new bag.

It is a matter of what the viewpoint is, I suppose.

I think in this specific case it might turn out to be
better for the scheduler to respond to what the device
throws at it, rather than the other way around.  And
in that case we need no feedback from scheduler to
cpu demux engine.

