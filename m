From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [PATCH] 2.6.22.6 NETWORKING [IPV4]: Always use source addr in
   skb to reply packet
Date: Tue, 18 Sep 2007 10:43:01 -0400
Message-ID: <46EFE3F5.5070201@tmr.com>
References: <20070918021617.GA15540@router.lepton.home> <20070917.192044.48396034.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ytht.net@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tmr.com ([64.65.253.246]:51485 "EHLO gaimboi.tmr.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758879AbXIROoY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Sep 2007 10:44:24 -0400
In-Reply-To: <20070917.192044.48396034.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: lepton <ytht.net@gmail.com>
> Date: Tue, 18 Sep 2007 10:16:17 +0800
> 
>> Hi,
>>   In some situation, icmp_reply and ip_send_reply will send
>>   out packet with the wrong source addr, the following patch
>>   will fix this.
>>
>>   I don't understand why we must use rt->rt_src in the current
>>   code, if this is a wrong fix, please correct me.
>>
>> Signed-off-by: Lepton Wu <ytht.net@gmail.com>
> 
> That the address is wrong is your opinion only :-)

Mine too, since an ICMP reply from an unexpected source IP is likely to 
be logged as a probe and dropped.
> 
> Source address selection is a rather complex topic, and
> here we are definitely purposefully using the source
> address selected by the routing lookup for the reply.

-- 
Bill Davidsen <davidsen@tmr.com>
   "We have more to fear from the bungling of the incompetent than from
the machinations of the wicked."  - from Slashdot
