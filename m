From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] net: ipv6: Allow netlink to set IPv6 address scope
Date: Mon, 17 Oct 2011 17:32:06 -0400
Message-ID: <4E9C9ED6.9080601@hp.com>
References: <20111005201559.E544016A599@drone1.mtv.corp.google.com> <4E931A46.1040905@hp.com> <CAKD1Yr29dAC+_=bT5-_W3XuTzoxMiEzOhpHvwrAzyA8NdcCjSQ@mail.gmail.com> <4E98981D.6080908@hp.com> <CAKD1Yr0EQ0P8e1V7pw48F2LMPCFKuZHm0DGoq8VM+LeKO_aZhQ@mail.gmail.com> <4E9B7A9F.7000302@hp.com> <CAKD1Yr0mnSM5EyVhJDPyq3Obe2WNiEjgQ=0uQ-r39Fg9WTsVmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: maze@google.com, yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:22266 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751344Ab1JQVcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 17:32:09 -0400
In-Reply-To: <CAKD1Yr0mnSM5EyVhJDPyq3Obe2WNiEjgQ=0uQ-r39Fg9WTsVmw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/2011 10:26 PM, Lorenzo Colitti wrote:
> RFC 3879 deprecated site-local addresses because the were non-unique and thus
> ambiguous, and if they leak, they cause problems. This is not an issue
> in the use
> case I presented, because the addresses are syntactically global
> addresses - they
> just don't have global reachability.

Not very global then :(

>> The MIF problem statement (in the RFC editor's queue) talks about this problem,
>> http://tools.ietf.org/html/draft-ietf-mif-problem-statement-15 - perhaps it's
>> better to work there to develop a more generic solution (using DHCPv6, RA
>> options, etc) before making this change?
> 
> I don't think it's a good idea. Waiting for an IETF working group to
> produce a standard
> when it doesn't even have a problem statement finalized could take years.

It would be useful to give some input there, even if the Linux-specific
implementation of any standard plays with bits in the ifaddr.

> Is there another reason why we shouldn't enable userspace to do what it wants?

In my opinion it just feels like a hack, because things won't work when your
wifi attaches to a walled garden, or there's a third interface - who wins the
tiebreaker?

I do see your point that it will help with the problem you're trying to solve,
hopefully someone else will offer their opinion.

-Brian
