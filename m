From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter/IPVS fixes for net
Date: Tue, 12 Jul 2016 10:22:06 -0700 (PDT)
Message-ID: <20160712.102206.1355401735643068344.davem@davemloft.net>
References: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1468339862-4028-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 12 Jul 2016 18:10:56 +0200

> The following patchset contains Netfilter/IPVS fixes for your net tree.
> they are:
> 
> 1) Fix leak in the error path of nft_expr_init(), from Liping Zhang.
> 
> 2) Tracing from nf_tables cannot be disabled, also from Zhang.
> 
> 3) Fix an integer overflow on 32bit archs when setting the number of
>    hashtable buckets, from Florian Westphal.
> 
> 4) Fix configuration of ipvs sync in backup mode with IPv6 address,
>    from Quentin Armitage via Simon Horman.
> 
> 5) Fix incorrect timeout calculation in nft_ct NFT_CT_EXPIRATION,
>    from Florian Westphal.
> 
> 6) Skip clash resolution in conntrack insertion races if NAT is in
>    place.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo.

> We're rather late in the release cycle of 4.7, so if these cannot
> get upstream I'll make sure to submit them to -stable, no problem.

I'm pretty sure there is going to be an -rc8, don't worry...

