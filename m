From: Dominik Kaspar <dokaspar.ietf@gmail.com>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Tue, 26 Apr 2011 23:16:27 +0200
Message-ID: <BANLkTik__3UV1MEnLBqO9XVJ0xUKPofdFg@mail.gmail.com>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
	<1303730701.2747.110.camel@edumazet-laptop>
	<BANLkTi=xns1Gdjyt-SX3yDETSQfO23rXXg@mail.gmail.com>
	<1303850622.2699.6.camel@edumazet-laptop>
	<BANLkTint2-Fg35T9SqWPm3nOaoc1d=ZEnQ@mail.gmail.com>
	<1303852092.2699.11.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Carsten Wolff <carsten@wolffcarsten.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:64505 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758778Ab1DZVQ2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 17:16:28 -0400
Received: by iyb14 with SMTP id 14so855006iyb.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 14:16:28 -0700 (PDT)
In-Reply-To: <1303852092.2699.11.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2011 at 11:08 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 26 avril 2011 =E0 23:04 +0200, Dominik Kaspar a =E9crit :
>
>> In these experiments, a queue size of 1000 packets was specified. I =
am
>> aware that this is typically referred to as "buffer bloat" and cause=
s
>> the RTT and the cwnd to grow excessively. The smaller I configure th=
e
>> queues, the more time it takes for TCP to "level up" to the aggregat=
e
>> throughput. By keeping the queues so large, I hope to more quickly
>> identify the reason why TCP is actually able to adjust to the immens=
e
>> multipath reordering. What parameters could be highly relevant, othe=
r
>> than the queue size?
>>
>
> losses of course ;)
>
> Real internet is full of packet losses, and probability of these loss=
es
> depends on queue sizes (RED like AQM)
>

No additional random loss is introduced (yet), so packet loss happens
only when the queue size of 1000 packets is hit. Since the queues are
configured overly large, packet loss rarely happens at all... of
course at the cost of a large RTT.

I suspect that artificially bloating the RTT somehow allows TCP to
better adjust to multipath reordering... just haven't got a clue why.

Cheers,
Dominik
