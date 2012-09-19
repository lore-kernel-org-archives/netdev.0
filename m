From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: HTB vs CoDel performance
Date: Wed, 19 Sep 2012 09:26:44 +0800
Message-ID: <CAF1ivSYQiXBOtzZdDUKEqWWsW5cgLgSkLs88Dvkppb02yN6wTg@mail.gmail.com>
References: <CAF1ivSZPpBkKk6mfhEu01bz6yP4KgJU8kK6cmeZ9e+kwH=EtiQ@mail.gmail.com>
	<1347961511.26523.216.camel@edumazet-glaptop>
	<CAF1ivSYweQgxbCd_ejHmDi5w7puRkE7MbpV_hczhXXDca5DJ7A@mail.gmail.com>
	<1347963353.26523.224.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: networking <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:44685 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab2ISB1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 21:27:36 -0400
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 57416DBCAE
	for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 09:26:46 +0800 (CST)
Received: by lbbgj3 with SMTP id gj3so450272lbb.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 18:26:44 -0700 (PDT)
In-Reply-To: <1347963353.26523.224.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 18, 2012 at 6:15 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Tue, 2012-09-18 at 17:56 +0800, Lin Ming wrote:
>
>> I need traffic priority/traffic shaping/rate control ... actually all
>> QoS features on the router.
>> And if I just set the rate to gigabit(no other settings), for example,
>>
>> # tc qdisc add dev eth10 root handle 20: htb default 1
>> # tc class add dev eth10 parent 20 classid 20:1 htb prio 2 rate
>> 1024Mbit ceil 1024Mbit burst 1281408b cburst 1281408b
>>
>> it should gain similar performance as pfifo_fast.
>>
>> codel has no rate control. So seems I have to find way to optimize htb?
>
> Are you really cpu limited ? You might hit some clocks artifacts.

Did you mean the cpu speed? It's an ARMv5 processor.
BogoMIPS	: 1196.03

>
> rate limiting to 1Gbps probably need high resolution timers.

High resolution timer is enabled.

>
> HTB is not the only way to rate limit.

I'll try other classful qdiscs.

Thanks.
