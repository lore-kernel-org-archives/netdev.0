From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xfrm: Correctly parse netlink msg from 32bits
 ip command on 64bits host
Date: Thu, 27 Feb 2014 18:52:20 -0500 (EST)
Message-ID: <20140227.185220.1897448102119943086.davem@davemloft.net>
References: <530C3B07.3090406@windriver.com>
	<1393348547.14067.18.camel@deadeye.wl.decadent.org.uk>
	<20140225191602.GD9965@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, fan.du@windriver.com,
	steffen.klassert@secunet.com, netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50364 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbaB0XwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:52:23 -0500
In-Reply-To: <20140225191602.GD9965@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue, 25 Feb 2014 20:16:02 +0100

> Ben Hutchings <ben@decadent.org.uk> wrote:
>> > On 2014年02月20日 17:59, Steffen Klassert wrote:
>> > > For now I think we should just refuse to do anything if someone tries
>> > > to configure ipsec with 32 bit tools on a 64 bit machine.
>> > 
>> > I'm fine with your point, and it would be a good choice to inform user about
>> > this behavior other than just creating non-working SA and SP for user.
> 
> It might be better to try to revive
> http://thread.gmane.org/gmane.linux.network/157118/focus=157122
> 
> which adds full compat support.

Agreed.
