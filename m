From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] net: hp-plus uses eip_poll
Date: Tue, 25 Nov 2008 22:03:16 -0800
Message-ID: <492CE6A4.5040404@oracle.com>
References: <20081125195400.dbb46066.randy.dunlap@oracle.com>	<20081125.210524.248687025.davem@davemloft.net>	<492CE204.4090904@oracle.com> <20081125.214920.86352252.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: randy.dunlap@oracle.com, netdev@vger.kernel.org, jgarzik@pobox.com,
	alan@lxorguk.ukuu.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:56843 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbYKZGDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 01:03:32 -0500
In-Reply-To: <20081125.214920.86352252.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Tue, 25 Nov 2008 21:43:32 -0800
> 
>> David Miller wrote:
>>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>> Date: Tue, 25 Nov 2008 19:54:00 -0800
>>>
>>>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>>>
>>>> hp-plus uses 8390p.c, so it should use eip_poll(), not ei_poll().
>>>>
>>>> drivers/built-in.o: In function `hpp_probe1':
>>>> hp-plus.c:(.init.text+0x9cbd): undefined reference to `ei_poll'
>>>>
>>>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
>>> I'll apply this to net-2.6
>>>
>>> But can you take a look at what I just pushed out to
>>> net-next-2.6 wrt. this driver and give me a hand untangling
>>> things there?
>>>
>>> Thanks a lot Randy!
>> Looks to me like both of this week's hp-plus patches (one to
>> drivers/net/Makefile & one to drivers/net/hp-plus.c) are
>> still needed there (unless you applied those patches but
>> didn't push or the push isn't showing up yet).
> 
> Ok.  I will need to merge.
> 
> But in net-next-2.6 that ->poll_controller is set in the
> hp-plus.c driver's netdev_ops structure.  That's what I
> wanted you to look at.

OK, it still uses ei_poll instead of eip_poll.
Needs to be changed.

-- 
~Randy
