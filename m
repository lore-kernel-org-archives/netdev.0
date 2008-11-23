From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: some optimizations in af_inet
Date: Sun, 23 Nov 2008 15:42:31 -0800 (PST)
Message-ID: <20081123.154231.114965188.davem@davemloft.net>
References: <4927AF61.40002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60452
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750818AbYKWXmb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2008 18:42:31 -0500
In-Reply-To: <4927AF61.40002@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sat, 22 Nov 2008 08:06:09 +0100

> 1) Use eq_net() in inet_netns_ok() to speedup socket creation if !CONFIG_NET_NS
> 
> 2) Reorder the tests about inet_ehash_secret generation (once only)
>    Use the unlikely() macro when testing if inet_ehash_secret already generated.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied, thanks Eric.
