From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Wed, 20 Jan 2016 18:57:36 -0800 (PST)
Message-ID: <20160120.185736.1574382642233693132.davem@davemloft.net>
References: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935216AbcAUC5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 21:57:37 -0500
In-Reply-To: <1453309444-2297-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 20 Jan 2016 18:03:58 +0100

> The following patchset contains Netfilter fixes for your net tree, they
> are:
> 
> 1) Fix accidental 3-times le/be conversion for 64-bits in nft_byteorder,
>    from Florian Westphal.
> 
> 2) Get rid of defensive cidr = 0 check in the ipset hash:netiface set
>    type which doesn't allow valid 0.0.0.0/0 elements, also from Florian.
> 
> 3) Relocate #endif in nft_ct counter support, this doesn't have any
>    relation with labels.
> 
> 4) Fix TCPMSS target for IPv6 when skb has CHECKSUM_COMPLETE, from
>    Eric Dumazet.
> 
> 5) Fix netdevice notifier leak from the error path of nf_tables_netdev.
> 
> 6) Safe conntrack hashtable resizing by introducing a global lock and
>    synchronize all buckets to avoid going over the maximum number of
>    preemption levels, from Sasha Levin.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.
