From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] ipv6: handle Redirect ICMP Message with no
 Redirected Header option
Date: Wed, 21 Aug 2013 20:44:07 -0700 (PDT)
Message-ID: <20130821.204407.1313812112339253041.davem@davemloft.net>
References: <521468C4.5020700@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40706 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752468Ab3HVDoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 23:44:10 -0400
In-Reply-To: <521468C4.5020700@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 21 Aug 2013 15:14:12 +0800

> +void ip6_redirect_no_header(struct sk_buff *skb, struct net *net, int oif,
> +			    u32 mark)
 ...
> +EXPORT_SYMBOL_GPL(ip6_redirect_no_header);

I don't think you need to export this to modules, this is in route.c and
the only user is in ndisc.c, both of which are linked together.

Please resubmit this with the symbol export removed, thanks.
