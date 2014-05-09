From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] neigh: set nud_state to NUD_INCOMPLETE when probing
 router reachability
Date: Thu, 08 May 2014 23:11:34 -0400 (EDT)
Message-ID: <20140508.231134.1238493636510322105.davem@davemloft.net>
References: <5369FDE7.3030001@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbenc@redhat.com, hannes@stressinduktion.org,
	netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756017AbaEIDLg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2014 23:11:36 -0400
In-Reply-To: <5369FDE7.3030001@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 7 May 2014 17:33:27 +0800

> In addition, use neigh_max_probes() to simplify function.
 ...
> -	atomic_set(&neigh->probes, NEIGH_VAR(neigh->parms, UCAST_PROBES));
...
> +	atomic_set(&neigh->probes, neigh_max_probes(neigh));

This is not an equivalent transformation, this changes things, in
particular APP_PROBES will be included now.

That's a functional change, not just "to simplify the function."

You'll therefore need to explain in detail why this is a valid
change and why it should be made.
