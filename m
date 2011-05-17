From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Suppress warning about combining
 enum flags by gcc 4.5
Date: Tue, 17 May 2011 15:26:51 -0400 (EDT)
Message-ID: <20110517.152651.1785846817320651943.davem@davemloft.net>
References: <1305656319.2848.28.camel@bwh-desktop>
	<20110517.142350.81148594119844192.davem@davemloft.net>
	<1305658121.2848.29.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756492Ab1EQT0z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 15:26:55 -0400
In-Reply-To: <1305658121.2848.29.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 May 2011 19:48:41 +0100

> gcc 4.5 warns about switch statements on enumerated types containing
> case values that are a bitwise-or of two enumerators for that type.
> The use of enumerators as flags is common practice, so I think the
> warning is wrong.  Keep the compiler quiet by casting the switch
> value.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Will this do?

What part of "get rid of the enum" is so hard to understand?

I'll say it again: Please get rid of the enum efx_fc_type

You can define bit positions if you like, because those will
be used as a proper enum, as unique bit positions within
a set of bits.  Then you can define macros as (1 << XXX)

Thanks.
