From: Li Yu <raise.sail@gmail.com>
Subject: Re: [PATCH 1/3] skbtrace v2: core feature and common events
Date: Fri, 19 Oct 2012 15:34:01 +0800
Message-ID: <50810269.2090504@gmail.com>
References: <5080F031.5040804@gmail.com> <1350630647.2293.194.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:60046 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752395Ab2JSHeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2012 03:34:06 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so169386pad.19
        for <netdev@vger.kernel.org>; Fri, 19 Oct 2012 00:34:05 -0700 (PDT)
In-Reply-To: <1350630647.2293.194.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B410=E6=9C=8819=E6=97=A5 15:10, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Fri, 2012-10-19 at 14:16 +0800, Li Yu wrote:
>> From: Li Yu <bingtian.ly@taobao.com>
>>
>> This patch contains:
>>
>> 1. The glue code of tracepoints subsystem and relay file system.
>> 2. API for particular networking trace points.
>> 3. The skb_rps_info trace point.
>>
>> Thanks
>>
>> Sign-off-by: Li Yu <bingtian.ly@taobao.com>
>>
>>   include/linux/skbtrace.h               |  478 ++++++++++++
>>   include/linux/skbtrace_api.h           |   73 +
>>   include/linux/skbuff.h                 |    7
>>   include/net/skbtrace_api_common.h      |   84 ++
>>   include/net/sock.h                     |   14
>>   include/trace/events/skbtrace.h        |   32
>>   include/trace/events/skbtrace_common.h |   41 +
>>   kernel/trace/Kconfig                   |    8
>>   net/core/Makefile                      |    2
>>   net/core/dev.c                         |    3
>>   net/core/net-traces.c                  |   24
>>   net/core/skbtrace-core.c               | 1226
>> +++++++++++++++++++++++++++++++++
>>   net/core/skbtrace-events-common.c      |   68 +
>>   net/core/skbuff.c                      |    5
>>   net/core/sock.c                        |    9
>>   15 files changed, 2073 insertions(+), 1 deletion(-)
>
>
> Hi
>
> Three months ago I gave my feedback about all this.
>
> And I dont think there is any real answer to my questions.
>
> There is 0 documentation, 0 example of how many bugs you found and fi=
xed
> thanks to this huge patch.
>
> Please fix a dozen of bugs with it, then we will be convinced it migh=
t
> be needed to review 2000 LOC
>

Sorry for confused, so far it only has some Chinese documents here,=20
http://rover-yu.github.com/skbtrace-kernel/using/index.html

I will supply the English version, add more documents on usage and chan=
ges.

Yu

> Thanks
>
>
>
