From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: enable sockets to use MSG_FASTOPEN by default
Date: Fri, 01 Nov 2013 08:29:21 -0700
Message-ID: <5273C8D1.5080608@hp.com>
References: <1383236372-1317-1-git-send-email-ycheng@google.com> <1383261598.19864.0.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org,
	ncardwell@google.com, sivasankar@cs.ucsd.edu
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0186.atlanta.hp.com ([15.193.32.63]:48888 "EHLO
	g6t0186.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751810Ab3KAP3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 11:29:25 -0400
In-Reply-To: <1383261598.19864.0.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/2013 04:19 PM, Eric Dumazet wrote:
> On Thu, 2013-10-31 at 09:19 -0700, Yuchung Cheng wrote:
>> Applications have started to use Fast Open (e.g., Chrome browser has
>> such an optional flag) and the feature has gone through several
>> generations of kernels since 3.7 with many real network tests. It's
>> time to enable this flag by default for applications to test more
>> conveniently and extensively.
>>
>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>> ---
>
> Acked-by: Eric Dumazet <edumazet@google.com>

Which TCP/IP stacks besides Linux have Fast Open at this point and for 
how long have they had it?  Basically, how prevalent are servers out 
there (both Internet and intranet) with support for Fast Open?

http://news.netcraft.com/archives/2013/11/01/november-2013-web-server-survey.html 
  doesn't go down to the OS level, and 
http://www.netcraft.com/internet-data-mining/ssl-survey/ is only from 
May and was in the context of SSL sides, but it does provide an 
interesting break-down of "OS share" which looks reasonably stable going 
back three years and so probably isn't too far off presently.

<insert the same sort of question about those firewalls and intermediate 
devices which make our lives so much fun here>

rick jones
