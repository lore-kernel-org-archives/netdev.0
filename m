From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Sun, 22 Mar 2015 16:57:30 -0400 (EDT)
Message-ID: <20150322.165730.425947572839143772.davem@davemloft.net>
References: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427049998-5665-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sun, 22 Mar 2015 19:46:32 +0100

> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> 1) Fix missing initialization of tuple structure in nfnetlink_cthelper
>    to avoid mismatches when looking up to attach userspace helpers to
>    flows, from Ian Wilson.
> 
> 2) Fix potential crash in nft_hash when we hit -EAGAIN in
>    nft_hash_walk(), from Herbert Xu.
> 
> 3) We don't need to indicate the hook information to update the
>    basechain default policy in nf_tables.
> 
> 4) Restore tracing over nfnetlink_log due to recent rework to
>    accomodate logging infrastructure into nf_tables.
> 
> 5) Fix wrong IP6T_INV_PROTO check in xt_TPROXY.
> 
> 6) Set IP6T_F_PROTO flag in nft_compat so we can use SYNPROXY6 and
>    REJECT6 from xt over nftables.

Pulled, thanks Pablo.
