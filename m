From: David Miller <davem@davemloft.net>
Subject: Re: Why is gre0 auto-created, and can we fix it?
Date: Tue, 03 Jan 2012 15:11:29 -0500 (EST)
Message-ID: <20120103.151129.2017623336171898647.davem@davemloft.net>
References: <4F035BDE.5060409@candelatech.com>
	<20120103.145931.2188599484081157576.davem@davemloft.net>
	<4F035F2C.1000003@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884Ab2ACULb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 15:11:31 -0500
In-Reply-To: <4F035F2C.1000003@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 03 Jan 2012 12:03:56 -0800

> On 01/03/2012 11:59 AM, David Miller wrote:
>> From: Ben Greear<greearb@candelatech.com>
>> Date: Tue, 03 Jan 2012 11:49:50 -0800
>>
>>> As far as I can tell, no other interfaces are auto-created
>>> in this manner.
>>
>> ip6tnl0 and sit0 do it too, just grep for alloc_netdev() under
>> net/{ipv4,ipv6}/
> 
> So, no changing the behaviour?

Probably too risky.  I think the exposure is on the order of ~16
years.
