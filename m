From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv6/route.c: packets originating on device match
 lo
Date: Mon, 25 Jun 2012 16:28:32 -0700 (PDT)
Message-ID: <20120625.162832.804773711822642700.davem@davemloft.net>
References: <20120625065030.GA28914@mcafee.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david_mccullough@mcafee.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756821Ab2FYX2d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:28:33 -0400
In-Reply-To: <20120625065030.GA28914@mcafee.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David McCullough <david_mccullough@mcafee.com>
Date: Mon, 25 Jun 2012 16:50:30 +1000

> @@ -931,6 +931,9 @@ struct dst_entry * ip6_route_output(stru
>  {
>  	int flags = 0;
>  
> +	if (fl6->flowi6_iif == 0)
> +		fl6->flowi6_iif = net->loopback_dev->ifindex;
> +		

Like ipv4, you should make this assignment unconditionally.

Thanks.
