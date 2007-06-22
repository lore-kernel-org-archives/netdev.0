From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET 00/02]: Secondary unicast address support
Date: Fri, 22 Jun 2007 13:36:32 +0200
Message-ID: <467BB440.3010700@trash.net>
References: <20070620180017.6685.70611.sendpatchset@localhost.localdomain>	<m13b0lf7mr.fsf@ebiederm.dsl.xmission.com>	<467ACDE1.7070907@trash.net> <m1sl8ldp6u.fsf@ebiederm.dsl.xmission.com> <467B2C39.1040208@trash.net> <467B404F.2080504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, jeff@garzik.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61525 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752331AbXFVLhI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jun 2007 07:37:08 -0400
In-Reply-To: <467B404F.2080504@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Greear wrote:
> Patrick McHardy wrote:
> 
>> Eric W. Biederman wrote:
>>
>>> For the macvlan hash you just use an upper byte.  Is that just a
>>> simple starting place, or do we not need a more complex hash.
>>>   
>>
>>
>> That gave me an idea, since the default addresses are random
>> anyway I'm now using an incrementing counter for the upper byte.
> 
> 
> Is there not a (relatively) easy way to hash the entire 6 bytes?
> 
> I'd prefer to be able to set the MACs to anything I want, without
> worrying about trivially hitting a worst-case hash scenario.


That would only happen if all your addresses have the same high
byte. I can't see a reason why you would want to do this, even
with manually configured addresses its still reasonable to
expect a uniform distribution.


