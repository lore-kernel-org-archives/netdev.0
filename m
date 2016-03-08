From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] Netfilter/IPVS updates for net-next
Date: Tue, 08 Mar 2016 14:28:49 -0500 (EST)
Message-ID: <20160308.142849.1605654925313096504.davem@davemloft.net>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43860 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750782AbcCHT2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 14:28:51 -0500
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue,  8 Mar 2016 11:00:40 +0100

> The following patchset contains Netfilter updates for your net-next tree,
> they are:
> 
> 1) Remove useless debug message when deleting IPVS service, from
>    Yannick Brosseau.
> 
> 2) Get rid of compilation warning when CONFIG_PROC_FS is unset in
>    several spots of the IPVS code, from Arnd Bergmann.
> 
> 3) Add prandom_u32 support to nft_meta, from Florian Westphal.
> 
> 4) Remove unused variable in xt_osf, from Sudip Mukherjee.
> 
> 5) Don't calculate IP checksum twice from netfilter ipv4 defrag hook
>    since fixing af_packet defragmentation issues, from Joe Stringer.
> 
> 6) On-demand hook registration for iptables from netns. Instead of
>    registering the hooks for every available netns whenever we need
>    one of the support tables, we register this on the specific netns
>    that needs it, patchset from Florian Westphal.
> 
> 7) Add missing port range selection to nf_tables masquerading support.
> 
> BTW, just for the record, there is a typo in the description of
> 5f6c253ebe93b0 ("netfilter: bridge: register hooks only when bridge
> interface is added") that refers to the cluster match as deprecated, but
> it is actually the CLUSTERIP target (which registers hooks
> inconditionally) the one that is scheduled for removal.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks Pablo!
