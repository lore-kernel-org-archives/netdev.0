From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] api: fix compatibility of linux/in.h with
 netinet/in.h
Date: Mon, 29 Jun 2015 19:08:32 -0700 (PDT)
Message-ID: <20150629.190832.783887118421744320.davem@davemloft.net>
References: <20150629145748.38bac115@uryu.home.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47275 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981AbbF3CIf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2015 22:08:35 -0400
In-Reply-To: <20150629145748.38bac115@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Mon, 29 Jun 2015 14:57:48 -1000

> u
> This fixes breakage to iproute2 build with recent kernel headers
> caused by:
>    commit a263653ed798216c0069922d7b5237ca49436007
>    Author: Pablo Neira Ayuso <pablo@netfilter.org>
>    Date:   Wed Jun 17 10:28:27 2015 -0500
> 
>    netfilter: don't pull include/linux/netfilter.h from netns headers
> 
> The issue is that definitions in linux/in.h overlap with those
> in netinet/in.h. This patch solves this by introducing the same
> mechanism as was used to solve the same problem with linux/in6.h
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
> 
> ---
> v2 -- fixed for iproute2, kernel
>       tested on several different orders of includes

This looks a lot better, applied, thanks Stephen.
