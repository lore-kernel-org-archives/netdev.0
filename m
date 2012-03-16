From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
Date: Fri, 16 Mar 2012 02:02:27 -0700 (PDT)
Message-ID: <20120316.020227.1430670417323299238.davem@davemloft.net>
References: <A1F3067C9B68744AA19F6802BAB8FFDC0DCE702F@TK5EX14MBXC223.redmond.corp.microsoft.com>
	<1331756072.6022.57.camel@edumazet-glaptop>
	<A1F3067C9B68744AA19F6802BAB8FFDC0DCE70A5@TK5EX14MBXC223.redmond.corp.microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, greearb@candelatech.com,
	netdev@vger.kernel.org, kys@microsoft.com,
	gregkh@linuxfoundation.org
To: haiyangz@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965068Ab2CPJDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 05:03:12 -0400
In-Reply-To: <A1F3067C9B68744AA19F6802BAB8FFDC0DCE70A5@TK5EX14MBXC223.redmond.corp.microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haiyang Zhang <haiyangz@microsoft.com>
Date: Wed, 14 Mar 2012 20:29:13 +0000

> 
> 
>> -----Original Message-----
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: Wednesday, March 14, 2012 4:15 PM
>> To: Haiyang Zhang
>> Cc: Ben Greear; David Miller; netdev; KY Srinivasan; Greg Kroah-Hartman
>> Subject: RE: [PATCH] net/hyperv: fix erroneous NETDEV_TX_BUSY use
>> 
>> On Wed, 2012-03-14 at 20:00 +0000, Haiyang Zhang wrote:
>> 
>> > Actually, I'm working on this bug, and have a patch under our internal
>> > review now. My fix is actually not freeing the SKB, and return
>> NETDEV_TX_BUSY.
>> >
>> > Even if the vmbus ring buffer is busy currently, it can be available
>> during
>> > the next re-try, because the host is taking away data from ring buffer.
>> The
>> > stop/wake queue mechanism is in the netvsc.c file.
>> >
>> > In the out-of-memory case, dropping packet and return NETDEV_TX_OK seems
>> fine.
>> 
>> That will be fine for net-next.
>> 
>> I sent a patch for current kernels, where obvious and minimal fixes
>> apply.
> 
> Sounds good. Thanks.
> 
> Reviewed-by: Haiyang Zhang <haiyangz@microsoft.com>
> 

APplied.
