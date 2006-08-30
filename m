From: Rick Jones <rick.jones2@hp.com>
Subject: Re: high latency with TCP connections
Date: Wed, 30 Aug 2006 16:00:42 -0700
Message-ID: <44F6189A.7000703@hp.com>
References: <20060830100734.GA22235@isil.ipib.msu.ru>	<20060830102727.11e11453@localhost.localdomain> <20060830.143955.55510936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, alex@sectorb.msk.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:38040 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1751603AbWH3XAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 19:00:45 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060830.143955.55510936.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 30 Aug 2006 10:27:27 -0700
> 
> 
>>Linux TCP implements "Appropriate Byte Count" (ABC) and this penalizes
>>applications that do small sends. The problem is that the other side
>>may be delaying acknowledgments.  If receiver doesn't acknowledge the
>>sender will limit itself to the congestion window. If the flow is light,
>>then you will be limited to 4 packets.
> 
> 
> Right.
> 
> However it occured to me the other day that ABC could be made smarter.
> If we sent small frames, ABC should account for that.

Is that part of the application of a byte-based RFC to packet-counting cwnd?

rick jones
