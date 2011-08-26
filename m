From: David Miller <davem@davemloft.net>
Subject: Re: Traffic shaping - class ID 16bit limit?
Date: Fri, 26 Aug 2011 12:53:41 -0400 (EDT)
Message-ID: <20110826.125341.1640427697242925942.davem@davemloft.net>
References: <CAO0uZ+-fv89Z3-9+vh5kN93xe=Uw8b=PSfnAqosOjUBP6PcVNg@mail.gmail.com>
	<20110825093937.2a8a1457@nehalam.ftrdhcpuser.net>
	<CAO0uZ+_6xC0gymfbu28PRK4SaVgkGaSbbe-PgXvZ4h-cPp8k2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: exa.exa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816Ab1HZQxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2011 12:53:44 -0400
In-Reply-To: <CAO0uZ+_6xC0gymfbu28PRK4SaVgkGaSbbe-PgXvZ4h-cPp8k2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Miroslav Kratochvil <exa.exa@gmail.com>
Date: Thu, 25 Aug 2011 19:06:58 +0200

>>> Technically the ClassID seems to be "hardcoded" as a 16bit value, but
>>> after some source searching, I haven't found any good reason for it to
>>> be 16-bit only.
>>
>> Granted it was a poor choice in the initial design.
>> It is wired into the API and changing it would be quite painful.
>>
> 
> I was feeling something like that would come.
> 
> If I get it correctly, the API change would consist of:
> 
> - some netlink protocol change
> - slight modification of qdisc_class_hash
> - modifications in all (four?) hierarchical schedulers
> - tiny expansion of userspace tc utility

There is precedence as we had to make the routing table rule ID larger
and were successfully able to do so using netlink attributes.
