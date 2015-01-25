From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipvlan: fix incorrect usage of IS_ERR() macro in
 IPv6 code path.
Date: Sun, 25 Jan 2015 00:24:45 -0800 (PST)
Message-ID: <20150125.002445.702364447839790923.davem@davemloft.net>
References: <1422165223-13496-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
	dan.carpenter@oracle.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60754 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751076AbbAYIYq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Jan 2015 03:24:46 -0500
In-Reply-To: <1422165223-13496-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sat, 24 Jan 2015 21:53:43 -0800

> The ip6_route_output() always returns a valid dst pointer unlike in IPv4
> case. So the validation has to be different from the IPv4 path. Correcting
> that error in this patch.
> 
> This was picked up by a static checker with a following warning -
> 
>    drivers/net/ipvlan/ipvlan_core.c:380 ipvlan_process_v6_outbound()
>         warn: 'dst' isn't an ERR_PTR
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
