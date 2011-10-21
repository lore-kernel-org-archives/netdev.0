From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Thu, 20 Oct 2011 21:25:19 -0700
Message-ID: <CAHo-OozPF1o0qD2PHHwskce=H4DpwR3FSTksLB31mF4K0Bdh4w@mail.gmail.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com>
	<4E931A46.1040905@hp.com>
	<CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com>
	<4E98981D.6080908@hp.com>
	<CAKD1Yr0EQ0P8e1V7pw48F2LMPCFKuZHm0DGoq8VM+LeKO_aZhQ@mail.gmail.com>
	<4E9B7A9F.7000302@hp.com>
	<CAKD1Yr0mnSM5EyVhJDPyq3Obe2WNiEjgQ=0uQ-r39Fg9WTsVmw@mail.gmail.com>
	<4E9C9ED6.9080601@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Lorenzo Colitti <lorenzo@google.com>, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:38354 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751432Ab1JUEZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 00:25:20 -0400
Received: by gyb13 with SMTP id 13so3498154gyb.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 21:25:20 -0700 (PDT)
In-Reply-To: <4E9C9ED6.9080601@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> RFC 3879 deprecated site-local addresses because the were non-unique and thus
>> ambiguous, and if they leak, they cause problems. This is not an issue
>> in the use
>> case I presented, because the addresses are syntactically global
>> addresses - they
>> just don't have global reachability.
>
> Not very global then :(

They're globally unique.
Global does not imply being able to reach the internet, or being able
to be reached from the internet.

Whatever the RFC's say, that's just a sad fact of life.

>> I don't think it's a good idea. Waiting for an IETF working group to
>> produce a standard
>> when it doesn't even have a problem statement finalized could take years.
>
> It would be useful to give some input there, even if the Linux-specific
> implementation of any standard plays with bits in the ifaddr.

I'm afraid this is a real problem _right_ now, a solution is required
and we can't really afford to wait a year while working groups work
out a bugfix.

> In my opinion it just feels like a hack, because things won't work when your
> wifi attaches to a walled garden, or there's a third interface - who wins the
> tiebreaker?

I would tend to agree that this is a little hacky... but, ultimately,
I always claim that policy should belong in userspace - not in the
kernel.
If userspace administrator wants to shoot himself, he can do that in
plenty of ways already.

> I do see your point that it will help with the problem you're trying to solve,
> hopefully someone else will offer their opinion.

I'm a little biased here, but I'd prefer my cellphone to just work ;-)

- Maciej
