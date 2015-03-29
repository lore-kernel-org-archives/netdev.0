From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/4 v2] ipvlan: fix addr hash list corruption
Date: Sun, 29 Mar 2015 12:23:25 -0700 (PDT)
Message-ID: <20150329.122325.255412967371199514.davem@davemloft.net>
References: <cover.1427476903.git.jbenc@redhat.com>
	<b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com, dcbw@redhat.com
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752376AbbC2TOl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 15:14:41 -0400
In-Reply-To: <b5d7fb60399f0a09914ff6dd94787132f40f5c0f.1427476903.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 27 Mar 2015 18:30:23 +0100

> @@ -622,7 +622,10 @@ static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *ip6_addr)
>  	addr->atype = IPVL_IPV6;
>  	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
>  	ipvlan->ipv6cnt++;
> -	ipvlan_ht_addr_add(ipvlan, addr);
> +	/* If the interface is not up, the address will be added to the hash
> +	 * list by ipvlan_open. */

Comments in the networking should be formatted:

	/* Like
	 * this.
	 */

Thanks.
