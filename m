From: Patrick McHardy <kaber@trash.net>
Subject: Re: Vlan interface nuisance
Date: Mon, 02 Mar 2009 10:44:55 +0100
Message-ID: <49ABAA97.4060103@trash.net>
References: <20090301204731.40ce346a@nehalam>	<20090301.205702.81302378.davem@davemloft.net>	<20090301210541.4585c199@nehalam> <20090301.212824.124808000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40055 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbZCBJo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2009 04:44:59 -0500
In-Reply-To: <20090301.212824.124808000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Stephen Hemminger <shemminger@vyatta.com>
> Date: Sun, 1 Mar 2009 21:05:41 -0800
> 
>> On Sun, 01 Mar 2009 20:57:02 -0800 (PST)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> From: Stephen Hemminger <shemminger@vyatta.com>
>>> Date: Sun, 1 Mar 2009 20:47:31 -0800
>>>
>>>> Why is interface created through netlink named 'vlan0' and
>>>> interface created through old vconfig called 'ethX.YY'.
>>>> Seems like the interface should be consistent.
>>> I think the netlink scheme is saner, and the idea is to
>>> transition people over to that.
>>>
>>> We can't change what vconfig uses, so what Patrick decided
>>> to do is pretty sane if you ask me.
>> This is missing:
> 
> You can just say you don't think the behavior is
> intentional.... :-/

Indeed, it was intentional not to have these IMO useless naming
schemes when you can simply supply the name of your choice when
creating the interface.

