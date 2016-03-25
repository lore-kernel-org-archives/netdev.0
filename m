From: David Miller <davem@davemloft.net>
Subject: Re: veth regression with =?iso-8859-7?B?ImRvbqJ0?= modify
 ip_summed; doing so treats packets with bad checksums as good."
Date: Fri, 25 Mar 2016 12:44:27 -0400 (EDT)
Message-ID: <20160325.124427.273071525698476869.davem@davemloft.net>
References: <56F4C8FD.7030907@candelatech.com>
	<CAM_iQpWwch3+6u+X0DBGyVSWttd7Nz2COdmq2q=G9BxisW52bA@mail.gmail.com>
	<56F56312.4080408@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, vijayp@vijayp.ca, netdev@vger.kernel.org,
	ej@evanjones.ca, cwang@twopensource.com
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbcCYQob (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 12:44:31 -0400
In-Reply-To: <56F56312.4080408@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Fri, 25 Mar 2016 09:10:58 -0700

> I am suspicious that this will break at least some drivers.  I
> grepped around for ip_summed, and found this, for instance:
> 
> davicom/dm9000.c
> 
>         /* The DM9000 is not smart enough to leave fragmented packets

An really old (circa 1997), not-oft-used, driver such as this is not
the place to be looking for correct usage of skb->ip_summed semantics.

I would never use whatever a driver like this does influence whether I
apply a bug fix or not.
