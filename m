From: David Ahern <dsahern@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Tue, 22 Aug 2017 09:43:45 -0700
Message-ID: <bf580154-aea9-4143-5d9c-df3764b5e745@gmail.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
 <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
 <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
 <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
 <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
 <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
 <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
 <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
 <1503406926.2499.20.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34183 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751172AbdHVQns (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 12:43:48 -0400
Received: by mail-pf0-f175.google.com with SMTP id h75so11703087pfh.1
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 09:43:47 -0700 (PDT)
In-Reply-To: <1503406926.2499.20.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/22/17 6:02 AM, Eric Dumazet wrote:
>>
>> net.core.netdev_max_backlog=10000
> This is an insane backlog.
> 

https://www.kernel.org/doc/Documentation/networking/scaling.txt

"== Suggested Configuration

Flow limit is useful on systems with many concurrent connections,
where a single connection taking up 50% of a CPU indicates a problem.
In such environments, enable the feature on all CPUs that handle
network rx interrupts (as set in /proc/irq/N/smp_affinity).

The feature depends on the input packet queue length to exceed
the flow limit threshold (50%) + the flow history length (256).
Setting net.core.netdev_max_backlog to either 1000 or 10000
performed well in experiments."
