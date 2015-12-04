From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 04 Dec 2015 16:37:01 -0500 (EST)
Message-ID: <20151204.163701.1543607078191101626.davem@davemloft.net>
References: <1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
	<CALx6S349Ub+UJSRN5UEt+0b76sVLzcxDbq_hZGaKkRzK-_gOrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, linville@tuxdriver.com,
	jesse@kernel.org, anjali.singhai@intel.com, netdev@vger.kernel.org,
	kiran.patil@intel.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754947AbbLDVhF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 16:37:05 -0500
In-Reply-To: <CALx6S349Ub+UJSRN5UEt+0b76sVLzcxDbq_hZGaKkRzK-_gOrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Fri, 4 Dec 2015 12:13:53 -0800

> On Fri, Dec 4, 2015 at 12:06 PM, David Miller <davem@davemloft.net> wrote:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Fri, 04 Dec 2015 20:59:05 +0100
>>
>>> Yes, I agree, I am totally with you here. If generic offloading can be
>>> realized by NICs I am totally with you that this should be the way to
>>> go. I don't see that coming in the next (small number of) years, so I
>>> don't see a reason to stop this patchset.
>>
>> If I just apply this and say "yeah ok", the message is completely lost
>> and your prediction about "small number of years" indeed will occur.
>>
>> However if I push back hard on this, as I will, then the message has
>> some chance of seeping back to the people designing these chips.
>>
>> So that's what I'm going to do, like it or not.
>>
>> Or can someone convince me that someone who understand this stuff
>> is telling the hardware guys to universally put 2's complement
>> checksums into the descriptors?
>>
> We're talking about 1's complement checksum (RFC1701). Just to be clear :-)

Right :)
