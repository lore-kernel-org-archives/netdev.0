From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] net: hp-plus uses eip_poll
Date: Tue, 25 Nov 2008 21:43:32 -0800
Message-ID: <492CE204.4090904@oracle.com>
References: <20081125195400.dbb46066.randy.dunlap@oracle.com> <20081125.210524.248687025.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, alan@lxorguk.ukuu.org.uk
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:61426 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751034AbYKZFns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Nov 2008 00:43:48 -0500
In-Reply-To: <20081125.210524.248687025.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Randy Dunlap <randy.dunlap@oracle.com>
> Date: Tue, 25 Nov 2008 19:54:00 -0800
> 
>> From: Randy Dunlap <randy.dunlap@oracle.com>
>>
>> hp-plus uses 8390p.c, so it should use eip_poll(), not ei_poll().
>>
>> drivers/built-in.o: In function `hpp_probe1':
>> hp-plus.c:(.init.text+0x9cbd): undefined reference to `ei_poll'
>>
>> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
> 
> I'll apply this to net-2.6
> 
> But can you take a look at what I just pushed out to
> net-next-2.6 wrt. this driver and give me a hand untangling
> things there?
> 
> Thanks a lot Randy!

Looks to me like both of this week's hp-plus patches (one to
drivers/net/Makefile & one to drivers/net/hp-plus.c) are
still needed there (unless you applied those patches but
didn't push or the push isn't showing up yet).

-- 
~Randy
