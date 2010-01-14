From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Subject: Re: [PATCH] [NET]: da.s_net not copied but assigned to itself in
 aarp_rcv()
Date: Thu, 14 Jan 2010 19:00:01 -0200
Message-ID: <20100114210001.GE20221@ghostprotocols.net>
References: <4B4F7F4B.8000302@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linux Networking Development Mailing List
	<netdev@vger.kernel.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:39997 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498Ab0ANVAI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2010 16:00:08 -0500
Content-Disposition: inline
In-Reply-To: <4B4F7F4B.8000302@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Thu, Jan 14, 2010 at 09:32:11PM +0100, Roel Kluin escreveu:
> da.s_net was not copied but assigned to itself.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Looks right, must be there for ages...

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> ---
> diff --git a/net/appletalk/aarp.c b/net/appletalk/aarp.c
> index 9d4adfd..f2b3b56 100644
> --- a/net/appletalk/aarp.c
> +++ b/net/appletalk/aarp.c
> @@ -819,7 +819,7 @@ static int aarp_rcv(struct sk_buff *skb, struct net_device *dev,
>  				ma = &ifa->address;
>  			else { /* We need to make a copy of the entry. */
>  				da.s_node = sa.s_node;
> -				da.s_net = da.s_net;
> +				da.s_net = sa.s_net;
>  				ma = &da;
>  			}
>  
