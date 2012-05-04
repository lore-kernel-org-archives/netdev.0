From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH net-next] tcp: be more strict before accepting ECN negociation
Date: Fri, 04 May 2012 11:48:49 -0700
Message-ID: <4FA42491.2020104@hp.com>
References: <1336144442.3752.348.camel@edumazet-glaptop> <4FA41B5B.5080103@hp.com> <1336155815.3752.365.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Perry Lorier <perryl@google.com>,
	Matt Mathis <mattmathis@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Wilmer van der Gaast <wilmer@google.com>,
	=?UTF-8?B?RGF2ZSBUw6RodA==?= <dave.taht@bufferbloat.net>,
	Ankur Jain <jankur@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:36989 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753831Ab2EDSsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 14:48:52 -0400
In-Reply-To: <1336155815.3752.365.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/04/2012 11:23 AM, Eric Dumazet wrote:
> On Fri, 2012-05-04 at 11:09 -0700, Rick Jones wrote:
>> What sort of networks were these?  Any chance it was some sort of
>> attempt to add ECN to FastOpen?
>
> Nothing to do with fastopen.
>
> Just take a look at a random http server and sample all SYN packets it
> receives.
>
> Some of them have TOS bits 0 or 1 set, or even both bits set.

I'll fire-up tcpdump on netperf.org:

tcpdump -i eth0 -vvv '(tcp[tcpflags] & tcp-syn != 0) && (ip[1] != 0x0)'

and see what appears.

rick
