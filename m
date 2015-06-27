From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] uapi: fix compatability of linux/in.h with
 netinet/in.h
Date: Sat, 27 Jun 2015 14:52:48 -0700 (PDT)
Message-ID: <20150627.145248.343550575965644423.davem@davemloft.net>
References: <20150625231206.4a9c3daf@uryu.home.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pablo@netfilter.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756AbbF0Vww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2015 17:52:52 -0400
In-Reply-To: <20150625231206.4a9c3daf@uryu.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Thu, 25 Jun 2015 23:12:06 -0400

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

Applied.
