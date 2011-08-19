From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: Re: Traceroute and "ping" sockets: some questions
Date: Fri, 19 Aug 2011 17:56:26 +0400
Message-ID: <4E4E6B8A.1030707@odu.neva.ru>
References: <4E4E46B4.9010909@odu.neva.ru>	<20110819.043816.1648681777223816477.davem@davemloft.net>	<4E4E4DF6.2020509@odu.neva.ru> <20110819.062249.2234872106788628654.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:34827 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751685Ab1HSN42 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 09:56:28 -0400
Received: from buc.odu.neva.ru (buc.odu.neva.ru [194.85.100.33])
	by mail2.odu.neva.ru (Postfix) with ESMTPA id 0379F14A8039
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 17:56:26 +0400 (MSD)
In-Reply-To: <20110819.062249.2234872106788628654.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>>> Why limit?  He can spam with UDP socket just as easily at any rate
>>> he pleases,
>>>        
>> Yes, but most cases such UDP is "one-way" spam (until services like
>> "echo 7/udp" are enabled).
>> For icmp echo, we normally receive icmp replies, hence it is
>> bidirectional crap. Which was not present before.
>>      
> Well, replace UDP with TCP syn flood.
>    

Well.

Why then there is "net/ipv4/ping_group_range" restrictions, with default 
values (low=1, high=0) which denies this way even for root?


Regards,
Dmitry
