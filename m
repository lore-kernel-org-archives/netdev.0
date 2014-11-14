From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fast_hash: clobber registers correctly for
 inline function use
Date: Fri, 14 Nov 2014 16:35:25 -0500 (EST)
Message-ID: <20141114.163525.859246902603470379.davem@davemloft.net>
References: <20141114.133829.1437047454714311242.davem@davemloft.net>
	<CAHA+R7NKrwE7F4k4wiaZRJ67QAhB9bUe8SdyuT8Ky3-wAou6cA@mail.gmail.com>
	<1415997733.15154.62.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, ogerlitz@mellanox.com, pshelar@nicira.com,
	jesse@nicira.com, jay.vosburgh@canonical.com,
	discuss@openvswitch.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45070 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161872AbaKNVf2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 16:35:28 -0500
In-Reply-To: <1415997733.15154.62.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 14 Nov 2014 21:42:13 +0100

> On Fr, 2014-11-14 at 11:02 -0800, Cong Wang wrote:
>> 
>> I am wondering, compare with alternative call, how slower is just
>> testing
>> cpu_has_xmm4_2?
> 
> I can test, but cpu_has_xmm4_2 expands into quite some code. I don't
> know if indirect function call or a test of this flag is faster. I'll
> test this.

I'm going to apply Jay's revert, and then you guys can take your time
sorting this out.
