From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Fri, 29 Aug 2008 11:29:34 +0400
Message-ID: <48B7A55E.4010603@openvz.org>
References: <E1KYxzB-00021T-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:60885 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751274AbYH2H3u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2008 03:29:50 -0400
In-Reply-To: <E1KYxzB-00021T-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> Pavel Emelyanov <xemul@openvz.org> wrote:
>> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
>> macros into functions the net/ipv4/built-in.o shrank significantly:
>>
>> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
>>
>> Turning the CONFIG_NET_NS option on makes this shrink even larger:
>>
>> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)
>>
>> So the question is - what was the reason to keep those as macros?
>> I thought about the possible performance questions, but netperf
>> didn't show any (I admit I just cannot cook it properly).
>>
>> The sample patch is here, but it's not good (EXPORTs for ipv6
>> and a better place for functions rather than net/ipv4/af_inet.c
>> are required).
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> What happened to Christoph Lameter's new per-cpu stuff? That would
> allows us to turn these into a single inc/add instruction.

I've never heard about it, but if you tell, that this would
make things *that* simple, then of course I will delay with
this patch.

> So I think we should put this patch on the back-burner until the
> status of the per-cpu stuff is settled.

OK, thanks.

> Thanks,

