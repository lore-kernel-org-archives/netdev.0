From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 08/12] vti6: Update the ipv6 side to use it's own
 receive hook.
Date: Sun, 02 Mar 2014 20:12:30 -0500 (EST)
Message-ID: <20140302.201230.888781684519764505.davem@davemloft.net>
References: <1393583483-12480-1-git-send-email-steffen.klassert@secunet.com>
	<1393583483-12480-9-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, christophe.gouault@6wind.com
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46812 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547AbaCCBMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2014 20:12:31 -0500
In-Reply-To: <1393583483-12480-9-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 28 Feb 2014 11:31:18 +0100

>  	if ((t = vti6_tnl_lookup(dev_net(skb->dev), &ipv6h->saddr,
>  				 &ipv6h->daddr)) != NULL) {
> -		struct pcpu_sw_netstats *tstats;
>  
>  		if (t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) {

Since you're removing all local variable declarations in this basic
block, you should remove the empty line as well.
