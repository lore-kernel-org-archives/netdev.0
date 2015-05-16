From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter fixes for net
Date: Sat, 16 May 2015 16:45:29 -0400 (EDT)
Message-ID: <20150516.164529.22426720638810224.davem@davemloft.net>
References: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37598 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750711AbbEPUpd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 16:45:33 -0400
In-Reply-To: <1431802038-4502-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 16 May 2015 20:47:14 +0200

> The following patchset contains Netfilter fixes for your net tree, they are:
> 
> 1) Fix a leak in IPVS, the sysctl table is not released accordingly when
>    destroying a netns, patch from Tommi Rantala.
> 
> 2) Fix a build error when TPROXY and socket are built-in but IPv6 defrag is
>    compiled as module, from Florian Westphal.
> 
> 3) Fix TCP tracket wrt. RFC5961 challenge ACK when in LAST_ACK state, patch
>    from Jesper Dangaard Brouer.
> 
> 4) Fix a bogus WARN_ON() in nf_tables when deleting a set element that stores
>    a map, from Mirek Kratochvil.

Pulled, thanks Pablo.
