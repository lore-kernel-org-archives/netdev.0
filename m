From: Hans de Goede <j.w.r.degoede@hhs.nl>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Wed, 27 Aug 2008 11:07:54 +0200
Message-ID: <48B5196A.2080502@hhs.nl>
References: <E1KYCV5-0002jW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, davej@redhat.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.versatel.nl ([62.58.50.89]:59669 "EHLO smtp2.versatel.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753067AbYH0I4q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 04:56:46 -0400
In-Reply-To: <E1KYCV5-0002jW-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Hans de Goede <j.w.r.degoede@hhs.nl> wrote:
>> Eric Dumazet wrote:
>>
>>> # dmesg | grep "TCP established hash"
>>> TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
>>> # time cat /proc/net/tcp >/dev/null
>>>
>>> real    0m0.091s
>>> user    0m0.001s
>>> sys     0m0.090s
>> As quoted above my idle x86_64, using the exact same hash table size, running 
>> 2.6.27-rc2.git1 uses 0.520 seconds for that same command, thats a difference of 
>> more then a factor 50 !!
> 
> That looks like a factor of 5 to me, not 50.
> 

Erm, you are completely right ofcourse.

Regards,

Hans
