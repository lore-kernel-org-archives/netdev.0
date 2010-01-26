From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] IPv6: conntrack: Use protocol-related initialization
 routine to initial queues of IPv6 connection track
Date: Tue, 26 Jan 2010 16:46:06 +0100
Message-ID: <4B5F0E3E.2070001@trash.net>
References: <20100125.233254.35824860.davem@davemloft.net>	<4B5EE2C6.6010802@cn.fujitsu.com>	<4B5EE436.3040204@trash.net> <20100126.051147.256313206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: shanwei@cn.fujitsu.com, yasuyuki.kozakai@toshiba.co.jp,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37348 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab0AZPqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jan 2010 10:46:10 -0500
In-Reply-To: <20100126.051147.256313206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Tue, 26 Jan 2010 13:46:46 +0100
> 
>> Oops, sorry. Not sure why I missed this, I've successfully
>> tested that change multiple times.
> 
> This situation is error prone, and I don't blame you for not catching
> it, because these common ipv6 fragmentation functions are assuming
> things about the layout of the first few struct members of the
> container in which the top level data structure lives.
> 
> What should happen is that when such an assumption exists, it should
> be explicitly codified.
> 
> Just like how we embed struct sock_common in both struct socket
> and in the TCP time-wait minisockets.

I'll see if I can come up with something to catch this kind of mistake
in the future.

> 
> Anyways, meanwhile I'll apply the fix.  And yes I know it needs
> to go to stable too... :-)

Thanks :)

