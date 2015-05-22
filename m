From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter fixes for net
Date: Fri, 22 May 2015 14:33:53 -0400 (EDT)
Message-ID: <20150522.143353.1996617853428090735.davem@davemloft.net>
References: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49556 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757207AbbEVSd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 14:33:56 -0400
In-Reply-To: <1432290846-4310-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 22 May 2015 12:34:03 +0200

> The following patchset contain Netfilter fixes for your net tree, they are:
> 
> 1) Fix a race in nfnetlink_log and nfnetlink_queue that can lead to a crash.
>    This problem is due to wrong order in the per-net registration and netlink
>    socket events. Patch from Francesco Ruggeri.
> 
> 2) Make sure that counters that userspace pass us are higher than 0 in all the
>    x_tables frontends. Discovered via Trinity, patch from Dave Jones.
> 
> 3) Revert a patch for br_netfilter to rely on the conntrack status bits. This
>    breaks stateless IPv6 NAT transformations. Patch from Florian Westphal.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
