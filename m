From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with a
 'bitwise' type
Date: Tue, 17 May 2011 17:14:12 -0400 (EDT)
Message-ID: <20110517.171412.1017451005914294196.davem@davemloft.net>
References: <1305658121.2848.29.camel@bwh-desktop>
	<20110517.152651.1785846817320651943.davem@davemloft.net>
	<1305666379.2848.45.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1EQVOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:14:17 -0400
In-Reply-To: <1305666379.2848.45.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 May 2011 22:06:19 +0100

> But that seems to result in discarding all type information for the
> flags. I would prefer to improve type checking.

That's why I don't want a solution like your cast patch, as that
takes the typing information away.

Accept that the compiler currently doesn't want to allow enums to be
used as bit-masks, don't paper around it.

I'm not applying this patch either, you think all of this "__force"
casting stuff is better?  No way.

