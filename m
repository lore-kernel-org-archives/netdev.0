From: David Miller <davem@davemloft.net>
Subject: Re: 3.0.23 WARNING: at net/ipv4/tcp_input.c:3375
 tcp_ack+0x1d62/0x2030()
Date: Mon, 19 Mar 2012 14:24:12 -0400 (EDT)
Message-ID: <20120319.142412.1284054436734248444.davem@davemloft.net>
References: <1332177220.9397.33.camel@edumazet-glaptop>
	<CADVnQynya96iG0cZjVGhtac2MP3AOBWODP7nUTMVhMd=6GWSOQ@mail.gmail.com>
	<AB9F1763-96B1-4AE4-8D94-73246EA08207@profihost.ag>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, eric.dumazet@gmail.com, greg@kroah.com,
	stable@vger.kernel.org, netdev@vger.kernel.org
To: s.priebe@profihost.ag
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030328Ab2CSSYZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Mar 2012 14:24:25 -0400
In-Reply-To: <AB9F1763-96B1-4AE4-8D94-73246EA08207@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Priebe <s.priebe@profihost.ag>
Date: Mon, 19 Mar 2012 19:20:39 +0100

> Am 19.03.2012 um 18:39 schrieb Neal Cardwell <ncardwell@google.com>:
> 
>> On Mon, Mar 19, 2012 at 09:10:51AM +0100, Stefan Priebe - Profihost AG wrote:
>>> WARNING: at net/ipv4/tcp_input.c:3375 tcp_ack+0x1d62/0x2030()
>> 
>> I double-checked the warning, and indeed in the 3.0.23 tcp_input.c at
>> 
>> http://git.kernel.org/?p=linux/kernel/git/stable/linux-stable.git;a=blob;f=net/ipv4/tcp_input.c;h=ee08f11ff21a802faa8b32efc1eb312e479878d6;hb=bf6a68d2a214e07f7c0d6538e00e17b826714160#l3375
>> 
>> that line is:
>>  WARN_ON((int)tp->sacked_out < 0);
>> 
>> So this indeed looks like the known issue that is fixed by the commits
>> Eric mentions, which are in 3.0.25.
>> 
>> neal
> 
> Perfect, thanks! 
> 
> Greg any ETA?

He released it the very second he told you to use it.
