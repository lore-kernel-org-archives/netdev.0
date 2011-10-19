From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: fix hang on removal of bridge via netlink
Date: Tue, 18 Oct 2011 23:24:55 -0400 (EDT)
Message-ID: <20111018.232455.1433707779693504596.davem@davemloft.net>
References: <1317921532.6433.13.camel@w-sridhar.beaverton.ibm.com>
	<20111006141941.437be127@nehalam.linuxnetplumber.net>
	<1317942169.6433.17.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46169 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab1JSDY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 23:24:59 -0400
In-Reply-To: <1317942169.6433.17.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Thu, 06 Oct 2011 16:02:49 -0700

> On Thu, 2011-10-06 at 14:19 -0700, Stephen Hemminger wrote:
>> Need to cleanup bridge device timers and ports when being bridge
>> device is being removed via netlink.
>> 
>> This fixes the problem of observed when doing:
>>  ip link add br0 type bridge
>>  ip link set dev eth1 master br0
>>  ip link set br0 up
>>  ip link del br0
>> 
>> which would cause br0 to hang in unregister_netdev because
>> of leftover reference count.
>> 
>> Reported-by: Sridhar Samudrala <sri@us.ibm.com>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Applied to 'net' and queued up for -stable, thanks.
