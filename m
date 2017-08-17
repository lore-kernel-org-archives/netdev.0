From: Akshat Kakkar <akshat.1984@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Thu, 17 Aug 2017 14:35:40 +0530
Message-ID: <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
 <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com> <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34269 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdHQJFl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 05:05:41 -0400
Received: by mail-pg0-f45.google.com with SMTP id u185so38808639pgb.1
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 02:05:41 -0700 (PDT)
In-Reply-To: <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 16, 2017 at 4:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-08-16 at 10:18 +0530, Akshat Kakkar wrote:
>> On Mon, Aug 14, 2017 at 2:37 PM, Akshat Kakkar <akshat.1984@gmail.com> wrote:
>> > I have centos 7.3 (Kernel 3.10) running on a server with 128GB RAM and
>> > 2 x 10 Core Xeon Processor.
>> > I have hosted a webserver on it and enabled ssh for remote maintenance.
>> > Previously it was running on Centos 6.3.
>> > After upgrading to CentOS 7.3, occasionally (probably when number of
>> > hits are more on the server), I am not able to create new connections
>> > (neither on web nor on ssh). Existing connections keeps on running
>> > fine.
>> >
>> > I did packet capturing using tcpdump to understand if its some
>> > intermediate network issue.
>> > What I found was the server is not replying for new SYN requests.
>> >
>> > So it's clear that its not at all application issue. Also, there are
>> > no logs in applications logs for any connections dropped, if any.
>> >
>> > I check my firewall rules if there is some rate limiting imposed.
>> > There is nothing in there.
>> >
>> > I check tc, if by mistake some rate limiting is imposed. There is
>> > nothing in there too.
>> >
>> > I have increased noOfFiles to 1000000 and other sysctl parameters, but
>> > the issue is still there.
>> >
>> > Has anybody experienced the same?
>> >
>> > How to go about? Anybody ... Please Help!!!
>>
>> Its getting lonely out here. Anybody there ???
>
> We wont help you unless you use a recent kernel.
>
> 3.10 misses all recent improvements in TCP stack (4 years of hard work)
>
>
>
>
>

I upgraded to 4.4 but still experiencing same issue.
Please help.
