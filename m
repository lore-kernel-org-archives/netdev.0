From: Ben Greear <greearb@candelatech.com>
Subject: Re: Question on netif_tx_queue_stopped
Date: Tue, 27 Jan 2009 22:12:43 -0800
Message-ID: <497FF75B.5060706@candelatech.com>
References: <497FF58D.50601@candelatech.com> <20090127.221043.244908230.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43817 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751946AbZA1GMq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 01:12:46 -0500
In-Reply-To: <20090127.221043.244908230.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Tue, 27 Jan 2009 22:05:01 -0800
>
>   
>> I'm doing some tests with pktgen and the 8139too (realtek) driver
>> in kernel 2.6.29-rc2.
>>
>> It seems that netif_tx_queue_stopped will return false fairly often even if the
>> cable is pulled from the NIC.
>>
>> Is that expected?
>>     
>
> Yep.
>
> Pulling the cable out only effects netif_carrier_ok().
>   
Thanks.  I'll just add a check for that as well before I try to transmit.

Thanks,
Ben

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


