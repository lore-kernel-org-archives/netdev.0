From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] net: ipv6: allow explicitly choosing optimistic
 addresses
Date: Thu, 05 Feb 2015 15:37:56 -0800 (PST)
Message-ID: <20150205.153756.1183417461754144671.davem@davemloft.net>
References: <1423047683-16267-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lorenzo@google.com,
	hannes@stressinduktion.org
To: ek@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbbBEXh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 18:37:59 -0500
In-Reply-To: <1423047683-16267-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Kline <ek@google.com>
Date: Wed,  4 Feb 2015 20:01:23 +0900

> RFC 4429 ("Optimistic DAD") states that optimistic addresses
> should be treated as deprecated addresses.  From section 2.1:
> 
>    Unless noted otherwise, components of the IPv6 protocol stack
>    should treat addresses in the Optimistic state equivalently to
>    those in the Deprecated state, indicating that the address is
>    available for use but should not be used if another suitable
>    address is available.
> 
> Optimistic addresses are indeed avoided when other addresses are
> available (i.e. at source address selection time), but they have
> not heretofore been available for things like explicit bind() and
> sendmsg() with struct in6_pktinfo, etc.
> 
> This change makes optimistic addresses treated more like
> deprecated addresses than tentative ones.
> 
> Signed-off-by: Erik Kline <ek@google.com>

Applied, thanks.
