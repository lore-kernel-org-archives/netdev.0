From: Ben Greear <greearb@candelatech.com>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 08:37:44 -0700
Message-ID: <46F7D9C8.7020101@candelatech.com>
References: <46F6905C.6030309@opengridcomputing.com>	 <20070923172803.GA11997@2ka.mipt.ru>	 <46F6A887.1030301@opengridcomputing.com> <1190571527.4256.78.camel@localhost> <46F75968.4010307@candelatech.com> <46F7C185.1030202@opengridcomputing.com> <46F7CC09.6070603@candelatech.com> <46F7D12A.7020607@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev@vger.kernel.org, Robert Olsson <Robert.Olsson@data.slu.se>
To: Steve Wise <swise@opengridcomputing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50770 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753287AbXIXPiP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2007 11:38:15 -0400
In-Reply-To: <46F7D12A.7020607@opengridcomputing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steve Wise wrote:
>
> Ben Greear wrote:
>> Steve Wise wrote:
>>> I think pktgen should be cloning the skbs using skb_clone().  Then 
>>> it will work for all devices, eh?
>> That might work, but it would decrease performance slightly (or, 
>> increase CPU load at least).
>
> Perf-wise, you could clone the skbs up front, then deliver them to the 
> nic in a tight loop.  This would mitigate the added overhead 
> introduced by calling skb_clone() in the loop doing transmits...
That only works if you are sending a small number of skbs.  You can't 
pre-clone several minutes worth of 10Gbe traffic
with any normal amount of RAM.

>>
>> Maybe a new option:  multi_clone
>>
>
> If the current code is busted, I think it should be fixed.
Well, it works fine when used correctly :)

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


