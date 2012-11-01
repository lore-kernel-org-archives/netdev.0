From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sockopt: Change getsockopt() of
 SO_BINDTODEVICE to return an interface name
Date: Thu, 01 Nov 2012 10:52:28 -0400 (EDT)
Message-ID: <20121101.105228.565623780714877960.davem@davemloft.net>
References: <509184D9.8030103@hp.com>
	<m2wqy6jrne.fsf@firstfloor.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, xemul@parallels.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761810Ab2KAOwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2012 10:52:35 -0400
In-Reply-To: <m2wqy6jrne.fsf@firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Wed, 31 Oct 2012 13:47:01 -0700

> Brian Haley <brian.haley@hp.com> writes:
> 
>> Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
>> will then require another call like if_indextoname() to get the actual interface
>> name, have it return the name directly.
>>
>> This also matches the existing man page description on socket(7) which mentions
>> the argument being an interface name.
>>
>> If the value has not been set, zero is returned and optlen will be set to zero
>> to indicate there is no interface name present.
> 
> That will break all existing programs using the return value, right?
> Better to fix the manpage

It never returned a value before, you could not getsockopt() on
SO_BINDTODEVICE previously.
