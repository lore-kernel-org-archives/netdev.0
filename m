From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [PATCH 0/4] New interface for memory accounting (take 1)
Date: Mon, 31 Dec 2007 13:46:59 -0500
Message-ID: <47793923.7050003@redhat.com>
References: <47775B25.7020401@redhat.com> <20071230.233413.117211235.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, vladislav.yasevich@hp.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	tyasui@redhat.com, mhiramat@redhat.com,
	satoshi.oshima.fk@hitachi.com, billfink@mindspring.com,
	andi@firstfloor.org, johnpol@2ka.mipt.ru,
	shemminger@linux-foundation.org, yoshfuji@linux-ipv6.org,
	yumiko.sugita.yf@hitachi.com, haoki@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47711 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbXLaSsE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2007 13:48:04 -0500
In-Reply-To: <20071230.233413.117211235.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David,

David Miller wrote:
> From: Hideo AOKI <haoki@redhat.com>
> Date: Sun, 30 Dec 2007 03:47:33 -0500
> 
>> The patch set consists of the following 4 patches.
>>
>> [1/4] introducing new memory accounting interface
>> [2/4] adding memory accounting points to consolidate functions
>> [3/4] updating TCP to use new interface
>> [4/4] updating SCTP to use new interface
> 
> I like this work very much and will add this to net-2.6.25
> But I will have to combine it all into one patch.
> 
> You cannot have one patch which breaks the build in any way.  All of
> the kernel must build properly after each patch in your patchset is
> applied.
> 
> Since patch 1 renames all of the sk_stream_*() functions, TCP and SCTP
> stop building.

That's correct.

> We enforce this rule, otherwise when users try to use "git bisect" to
> find out where regressions are added, they will get stuck in places
> like this where the tree will not build due to such careless
> changesets.

Thank you for your explanation. To be honest, I didn't know the rule
exactly. I am so sorry for sending inconvenient patch set.

Best regards,
Hideo

-- 
Hitachi Computer Products (America) Inc.
