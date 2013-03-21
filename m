From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix p3_gelic_net sparse warnings
Date: Thu, 21 Mar 2013 17:17:23 -0400 (EDT)
Message-ID: <20130321.171723.2170130040090928680.davem@davemloft.net>
References: <1363898133.1075.43.camel@smoke>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: geoff@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47173 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752965Ab3CUVRY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 17:17:24 -0400
In-Reply-To: <1363898133.1075.43.camel@smoke>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geoff Levand <geoff@infradead.org>
Date: Thu, 21 Mar 2013 13:35:33 -0700

> Fix these sparse warnings:
> 
>   ps3_gelic_net.c: error: marked inline, but without a definition
> 
> Signed-off-by: Geoff Levand <geoff@infradead.org>
> ---
> 
> Hi Dave,
> 
> Please queue for 3.10.  Thanks.

I'd rather you removed all of the inline tags from this foo.c
file, they are pointless with modern compilers.
