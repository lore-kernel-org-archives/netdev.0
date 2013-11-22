From: yan cui <ccuiyyan@gmail.com>
Subject: Re: dynamic TCP algorithms switching
Date: Fri, 22 Nov 2013 18:21:12 -0500
Message-ID: <CAAVq3rnmWUAzDGy9_nMLsbx++opgZpuYtG34VpZEBbJ2psBnZw@mail.gmail.com>
References: <CAAVq3rnxE92PsJOChr+H52k5QfG7E=hAjsohK4Um0ZRO9TdYuA@mail.gmail.com>
	<20131122145621.344fa999@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:63136 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338Ab3KVXVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Nov 2013 18:21:15 -0500
In-Reply-To: <20131122145621.344fa999@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Then, why include so many (current Linux has 10+ TCP congestion algorithms)
algorithms? For users who want to deploy their application on Linux
and if the applications
are system resource intensive, they always want to tune the
configurations of the operating systems for the last piece of
performance. If they do so, maybe they are confused
about which TCP congestion algorithm to use for their environment. So,
the only way is to try each algorithm one by one. I understand the
setting of the default TCP congestion
algorithm to be Cubic means that it works well for most environments.
But if others
are seldom used, or can be replace with another implementation.
Why not just remove from the kernel?

Yan

2013/11/22 Stephen Hemminger <stephen@networkplumber.org>:
> On Fri, 22 Nov 2013 17:49:58 -0500
> yan cui <ccuiyyan@gmail.com> wrote:
>
>> Hi all:
>>
>>    Currently, Linux has kinds of TCP congestion algorithms, such as
>> reno, cubic, bic, hybla, ...., and each TCP congestion algorithm has
>> its target networking environment. I just wonder to know is it
>> possible to do dynamic TCP algorithm switching? In other words, the
>> system has a combined TCP congestion algorithm (say, TCP-auto), and it
>> behaves like one of the integrated TCP congestion algorithms according
>> to different detected networking environment, but can switch to a
>> different one. For example, TCP-auto totally uses the set of
>> congestion control operations in TCP-cubic by default, but when it
>> detects that the current OS uses wireless networking, it switches to
>> some wireless friendly TCP congestion algorithm. Does Linux have some
>> features like that, or do you (networking developers and users) care
>> about it?
>>
>> Best Wishes!
>>
>
> You overestimate the advantage of one verus the other.
> It is possible to control algorithm on per-socket, and per-route
> but other than benchmarking there or bulk transfer for normal net
> traffic Cubic works fine for all environments.



-- 
Think big; Dream impossible; Make it happen.
