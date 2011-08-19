From: Dmitry Butskoy <buc@odusz.so-cdu.ru>
Subject: Re: Traceroute and "ping" sockets: some questions
Date: Fri, 19 Aug 2011 16:22:38 +0400
Message-ID: <4E4E558E.5050905@odu.neva.ru>
References: <4E4E46B4.9010909@odu.neva.ru> <20110819.043816.1648681777223816477.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.odu.neva.ru ([194.85.100.6]:38187 "EHLO mail2.odu.neva.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153Ab1HSMWk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Aug 2011 08:22:40 -0400
Received: from buc.odu.neva.ru (buc.odu.neva.ru [194.85.100.33])
	by mail2.odu.neva.ru (Postfix) with ESMTPA id DFD8514A8039
	for <netdev@vger.kernel.org>; Fri, 19 Aug 2011 16:22:38 +0400 (MSD)
In-Reply-To: <20110819.043816.1648681777223816477.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
>> - Are there any plans to implement some "rate control" (maybe
>> - sysctl-configurable too), to restrict unprivileged users to send icmp
>> - echoes too fast (ie. faster than 200 ms -- the current ping(8)
>> - restriction)?
>>      
> Why limit?  He can spam with UDP socket just as easily at any rate
> he pleases,
>    
Yes, but most cases such UDP is "one-way" spam (until services like 
"echo 7/udp" are enabled).
For icmp ping, we normally receive icmp replies, hence it is 
bidirectional crap. Which was not present before.

Besides that ping(8) is normally present in the system even if C 
development is not installed (ie. user cannot build its spam software at 
the host etc...)

Regards,
Dmitry
http://www.fedoraproject.org/wiki/DmitryButskoy
