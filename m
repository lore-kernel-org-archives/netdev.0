From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 8 Jul 2016 18:17:57 +0400
Message-ID: <CAOp4FwTgvOP504nmRVejZzqYia2Z=WdGa2Fd7e4TZ0hc7YfHcA@mail.gmail.com>
References: <577FAFFD.2020306@gmx.de> <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Toralf_F=C3=B6rster?= <toralf.foerster@gmx.de>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33765 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754807AbcGHOR6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 10:17:58 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so7330921pac.0
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 07:17:58 -0700 (PDT)
In-Reply-To: <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 8, 2016 at 6:14 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> On Fri, 2016-07-08 at 15:51 +0200, Toralf F=C3=B6rster wrote:
>> I do run a 4.6.3 hardened Gentoo kernel at a commodity i7 server. A
>> DDoS with about 300 MBit/sec over 5 mins resulted an issue for ipv6 =
at
>> that system.
>>
>> The IPv6 monitoring from my ISP told my that the to be monitored
>> services (80, 443, 52222) weren't reachable any longer at ipv6 (at
>> ipv4 there was no issue). Restarting the NIC brought back green ligh=
ts
>> for the services at the ipv6 ports too.
>
> Hard to tell without knowing DDOS details, but IPv6 lacks some
> scalability improvements found in IPv4.
>
> IPv4 no longer has a routing cache, but IPv6 still has one.
>

Any pointers as to which part of the kernel to look for to implement
one for IPv6 ?


> Are you sure conntrack is needed at all ?
>
>
