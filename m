From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ip6_tunnel: fix error code when tunnel exists
Date: Fri, 13 Mar 2015 12:32:31 -0400 (EDT)
Message-ID: <20150313.123231.1641333637059823788.davem@davemloft.net>
References: <1426251537-31870-1-git-send-email-nicolas.dichtel@6wind.com>
	<1426254227.11398.183.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	me@pierre-cheynier.net, steffen.klassert@secunet.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51164 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751481AbbCMQcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 12:32:33 -0400
In-Reply-To: <1426254227.11398.183.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Mar 2015 06:43:47 -0700

> 
> These IS_ERR_OR_NULL(t) looks like defensive/lazy programming to me.
 ...
> I wish we get rid of all IS_ERR_OR_NULL() uses in networking tree,
> instead of adding plenty of them.

+1
