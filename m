From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH v2 net] tcp: md5: do not use alloc_percpu()
Date: Thu, 23 Oct 2014 17:36:15 -0600
Message-ID: <544990EF.6090803@gmail.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>	 <5448A72D.1050806@cumulusnetworks.com>	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>	 <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>	 <5449689B.9040806@gmail.com> <1414105068.20845.38.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Crestez Dan Leonard <cdleonard@gmail.com>,
	netdev@vger.kernel.org,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:41709 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754019AbaJWXg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 19:36:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id kx10so1003pab.12
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 16:36:25 -0700 (PDT)
In-Reply-To: <1414105068.20845.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/23/14, 4:57 PM, Eric Dumazet wrote:
> On Thu, 2014-10-23 at 14:44 -0600, David Ahern wrote:
>
>> global variables do not need to be initialized to 0.
>>
>
> Compilers are generating the same code nowadays.
> They place such zero variables in bss anyway.
> They finally got this right, maybe years ago.
>
>
> $ nm -v net/ipv4/tcp.o | grep populated
> 0000000000000078 b tcp_md5sig_pool_populated

Right. I was referring to coding standards. As I recall checkpatch 
throws a warning about it.

David
