From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: pktgen question
Date: Mon, 24 Sep 2007 10:00:58 -0500
Message-ID: <46F7D12A.7020607@opengridcomputing.com>
References: <46F6905C.6030309@opengridcomputing.com>	 <20070923172803.GA11997@2ka.mipt.ru>	 <46F6A887.1030301@opengridcomputing.com> <1190571527.4256.78.camel@localhost> <46F75968.4010307@candelatech.com> <46F7C185.1030202@opengridcomputing.com> <46F7CC09.6070603@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	netdev@vger.kernel.org, Robert Olsson <Robert.Olsson@data.slu.se>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:54634 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752339AbXIXPA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2007 11:00:58 -0400
In-Reply-To: <46F7CC09.6070603@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Ben Greear wrote:
> Steve Wise wrote:
>> I think pktgen should be cloning the skbs using skb_clone().  Then it 
>> will work for all devices, eh?
> That might work, but it would decrease performance slightly (or, 
> increase CPU load at least).

Perf-wise, you could clone the skbs up front, then deliver them to the 
nic in a tight loop.  This would mitigate the added overhead introduced 
by calling skb_clone() in the loop doing transmits...

> 
> Maybe a new option:  multi_clone
> 

If the current code is busted, I think it should be fixed.

My 2 cents.

Steve.
