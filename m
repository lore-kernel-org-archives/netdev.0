From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cgroup: null ptr dereference in netprio cgroup
 during init
Date: Wed, 18 Jul 2012 11:44:14 -0700 (PDT)
Message-ID: <20120718.114414.1502102915415545793.davem@davemloft.net>
References: <20120718182711.22872.95370.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, nhorman@tuxdriver.com,
	mark.d.rustad@intel.com, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: john.r.fastabend@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37222 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755509Ab2GRSoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:44:15 -0400
In-Reply-To: <20120718182711.22872.95370.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.r.fastabend@intel.com>
Date: Wed, 18 Jul 2012 11:27:11 -0700

> @@ -27,7 +27,9 @@ static DEFINE_MUTEX(net_mutex);
>  LIST_HEAD(net_namespace_list);
>  EXPORT_SYMBOL_GPL(net_namespace_list);
>  
> -struct net init_net;
> +struct net init_net = {
> +			.count = ATOMIC_INIT(0),
> +		      };
>  EXPORT_SYMBOL(init_net);

That's some fancy indentation you've got there cowboy.
