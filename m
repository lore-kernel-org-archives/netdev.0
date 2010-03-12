From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] rps: Receive Packet Steering
Date: Fri, 12 Mar 2010 14:32:22 -0800 (PST)
Message-ID: <20100312.143222.225624026.davem@davemloft.net>
References: <alpine.DEB.1.00.1003121210050.25665@pokey.mtv.corp.google.com>
	<20100312142001.41cd7dd2@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57047
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932757Ab0CLWcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 17:32:03 -0500
In-Reply-To: <20100312142001.41cd7dd2@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 12 Mar 2010 14:20:01 -0800

> On Fri, 12 Mar 2010 12:13:12 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
> 
>> +++ b/include/linux/netdevice.h
>> @@ -223,6 +223,7 @@ struct netif_rx_stats {
>>  	unsigned dropped;
>>  	unsigned time_squeeze;
>>  	unsigned cpu_collision;
>> +	unsigned received_rps;
> 
> Maybe received_rps should be unsigned long so that
> it could be 64 bit on 64 bit platforms?

They all can be made 64-bit since they are only
exported via /proc

So this is completely seperate from the rps changes.
