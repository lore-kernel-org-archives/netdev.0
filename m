From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Make rt->fl.iif tests lest obscure.
Date: Thu, 11 Nov 2010 16:36:17 -0800 (PST)
Message-ID: <20101111.163617.15250206.davem@davemloft.net>
References: <20101111.162814.35035010.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60242
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751505Ab0KLAfw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Nov 2010 19:35:52 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 985C424C089
	for <netdev@vger.kernel.org>; Thu, 11 Nov 2010 16:36:17 -0800 (PST)
In-Reply-To: <20101111.162814.35035010.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 11 Nov 2010 16:28:14 -0800 (PST)

> diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
> index 94a9eb1..9aad1c0 100644
> --- a/net/decnet/dn_route.c
> +++ b/net/decnet/dn_route.c
> @@ -1181,7 +1181,7 @@ static int __dn_route_output_key(struct dst_entry **pprt, const struct flowi *fl

Anyone looking at this closely will notice that I need to redo these
decnet parts.

Updated patch coming up.
