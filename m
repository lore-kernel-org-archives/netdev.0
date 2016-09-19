From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: fallback to full lookup if table lookup is
 unsuitable
Date: Mon, 19 Sep 2016 00:58:57 -0400 (EDT)
Message-ID: <20160919.005857.553516799273302087.davem@davemloft.net>
References: <20160916125531.3486-1-vincent@bernat.im>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dsa@cumulusnetworks.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: vincent@bernat.im
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53004 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750786AbcISE7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 00:59:04 -0400
In-Reply-To: <20160916125531.3486-1-vincent@bernat.im>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vincent Bernat <vincent@bernat.im>
Date: Fri, 16 Sep 2016 14:55:31 +0200

> @@ -1808,6 +1808,30 @@ static struct rt6_info *ip6_nh_lookup_table(struct net *net,
>  	return rt;
>  }
>  
> +static int ip6_nh_valid(struct rt6_info *grt,
> +			struct net_device **dev, struct inet6_dev **idev) {
> +	int ret = 0;

First, this is not formatted properly.  The openning brace should start
on a new line.

Second, please use "bool", "true", and "false" for the return value.

Thanks.
