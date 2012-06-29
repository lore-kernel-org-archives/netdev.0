From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 01/02] net/ipv4: VTI support rx-path hook in
 xfrm4_mode_tunnel.
Date: Thu, 28 Jun 2012 18:00:43 -0700 (PDT)
Message-ID: <20120628.180043.1526226627406865120.davem@davemloft.net>
References: <20120629005225.GA4494@debian-saurabh-64.vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: saurabh.mohan@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58033 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753788Ab2F2BAn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 21:00:43 -0400
In-Reply-To: <20120629005225.GA4494@debian-saurabh-64.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saurabh <saurabh.mohan@vyatta.com>
Date: Thu, 28 Jun 2012 17:52:25 -0700

> +	for (pprev = &rcv_notify_handlers;
> +		(t = rcu_dereference_protected(*pprev,
> +		lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
> +		pprev = &t->next) {

Please indent this properly:

	for (x;
	     y;
	     z) {


x, y, and z must all line up to the same column.

> +	for (pprev = &rcv_notify_handlers;
> +		(t = rcu_dereference_protected(*pprev,
> +		lockdep_is_held(&xfrm4_mode_tunnel_input_mutex))) != NULL;
> +		pprev = &t->next) {

Likewise.

> +#define for_each_input_rcu(head, handler)	\
> +	for (handler = rcu_dereference(head);	\
> +		handler != NULL;		\
> +		handler = rcu_dereference(handler->next))  \

Likewise.
