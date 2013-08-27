From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6:examine the IP source address legitimacy
Date: Tue, 27 Aug 2013 12:32:13 -0400 (EDT)
Message-ID: <20130827.123213.1673375175621319814.davem@davemloft.net>
References: <521C90A0.60708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314Ab3H0QcR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 12:32:17 -0400
In-Reply-To: <521C90A0.60708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Tue, 27 Aug 2013 19:42:24 +0800

>  	rt = (struct rt6_info *) dst;
> -	if (rt == net->ipv6.ip6_null_entry) {
> +	if (rt == net->ipv6.ip6_null_entry || !ipv6_addr_equal(&rt->rt6i_gateway, &iph->saddr)) {

This line is significantly longer than 80 columns, please do not
create such long lines.
