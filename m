From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: enable sockets to use MSG_FASTOPEN by default
Date: Fri, 1 Nov 2013 09:09:16 -0700
Message-ID: <CAK6E8=dD+ThgXwuPnKZreEQGUkL5919f91z+fXRYwBxi91ZHYQ@mail.gmail.com>
References: <1383236372-1317-1-git-send-email-ycheng@google.com>
 <1383261598.19864.0.camel@edumazet-glaptop2.roam.corp.google.com> <5273C8D1.5080608@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Sivasankar Radhakrishnan <sivasankar@cs.ucsd.edu>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:54878 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab3KAQJi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 12:09:38 -0400
Received: by mail-ie0-f172.google.com with SMTP id tp5so7988001ieb.3
        for <netdev@vger.kernel.org>; Fri, 01 Nov 2013 09:09:37 -0700 (PDT)
In-Reply-To: <5273C8D1.5080608@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 1, 2013 at 8:29 AM, Rick Jones <rick.jones2@hp.com> wrote:
> On 10/31/2013 04:19 PM, Eric Dumazet wrote:
>>
>> On Thu, 2013-10-31 at 09:19 -0700, Yuchung Cheng wrote:
>>>
>>> Applications have started to use Fast Open (e.g., Chrome browser has
>>> such an optional flag) and the feature has gone through several
>>> generations of kernels since 3.7 with many real network tests. It's
>>> time to enable this flag by default for applications to test more
>>> conveniently and extensively.
>>>
>>> Signed-off-by: Yuchung Cheng <ycheng@google.com>
>>> Signed-off-by: Neal Cardwell <ncardwell@google.com>
>>> ---
>>
>>
>> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
> Which TCP/IP stacks besides Linux have Fast Open at this point and for how
> long have they had it?  Basically, how prevalent are servers out there (both
> Internet and intranet) with support for Fast Open?
google.com supports it. we are working on enabling more Android and
ChromeOS to use it.

>
> http://news.netcraft.com/archives/2013/11/01/november-2013-web-server-survey.html
> doesn't go down to the OS level, and
> http://www.netcraft.com/internet-data-mining/ssl-survey/ is only from May
> and was in the context of SSL sides, but it does provide an interesting
> break-down of "OS share" which looks reasonably stable going back three
> years and so probably isn't too far off presently.
>
> <insert the same sort of question about those firewalls and intermediate
> devices which make our lives so much fun here>
>
> rick jones
>
