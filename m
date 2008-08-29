From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC][PATCH] Turn part of SNMP accounting macros into functions
Date: Fri, 29 Aug 2008 17:01:33 +1000
Message-ID: <E1KYxzB-00021T-00@gondolin.me.apana.org.au>
References: <48B5815D.4010005@openvz.org>
Cc: netdev@vger.kernel.org
To: xemul@openvz.org (Pavel Emelyanov)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33148 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750725AbYH2HBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 03:01:36 -0400
In-Reply-To: <48B5815D.4010005@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov <xemul@openvz.org> wrote:
> After turning IP_XXX_STATS, TCP_XXX_STATS and NET_XXX_STATS from
> macros into functions the net/ipv4/built-in.o shrank significantly:
> 
> add/remove: 14/0 grow/shrink: 0/67 up/down: 482/-2246 (-1764)
> 
> Turning the CONFIG_NET_NS option on makes this shrink even larger:
> 
> add/remove: 14/0 grow/shrink: 0/67 up/down: 478/-2646 (-2168)
> 
> So the question is - what was the reason to keep those as macros?
> I thought about the possible performance questions, but netperf
> didn't show any (I admit I just cannot cook it properly).
> 
> The sample patch is here, but it's not good (EXPORTs for ipv6
> and a better place for functions rather than net/ipv4/af_inet.c
> are required).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

What happened to Christoph Lameter's new per-cpu stuff? That would
allows us to turn these into a single inc/add instruction.

So I think we should put this patch on the back-burner until the
status of the per-cpu stuff is settled.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
