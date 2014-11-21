From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net
Date: Fri, 21 Nov 2014 00:12:59 -0500 (EST)
Message-ID: <20141121.001259.557583673841588271.davem@davemloft.net>
References: <1416486651-12271-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750704AbaKUFNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 00:13:01 -0500
In-Reply-To: <1416486651-12271-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 20 Nov 2014 13:30:49 +0100

> The following patchset contains two bugfixes for your net tree, they are:
> 
> 1) Validate netlink group from nfnetlink to avoid an out of bound array
>    access. This should only happen with superuser priviledges though.
>    Discovered by Andrey Ryabinin using trinity.
> 
> 2) Don't push ethernet header before calling the netfilter output hook
>    for multicast traffic, this breaks ebtables since it expects to see
>    skb->data pointing to the network header, patch from Linus Luessing.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
