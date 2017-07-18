From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter fixes for net
Date: Tue, 18 Jul 2017 12:03:40 -0700 (PDT)
Message-ID: <20170718.120340.1012556068669757824.davem@davemloft.net>
References: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54626 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751505AbdGRTDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 15:03:41 -0400
In-Reply-To: <1500372839-6735-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 18 Jul 2017 12:13:54 +0200

> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> 1) Missing netlink message sanity check in nfnetlink, patch from
>    Mateusz Jurczyk.
> 
> 2) We now have netfilter per-netns hooks, so let's kill global hook
>    infrastructure, this infrastructure is known to be racy with netns.
>    We don't care about out of tree modules. Patch from Florian Westphal.
> 
> 3) find_appropriate_src() is buggy when colissions happens after the
>    conversion of the nat bysource to rhashtable. Also from Florian.
> 
> 4) Remove forward chain in nf_tables arp family, it's useless and it is
>    causing quite a bit of confusion, from Florian Westphal.
> 
> 5) nf_ct_remove_expect() is called with the wrong parameter, causing
>    kernel oops, patch from Florian Westphal.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks a lot.

What about that change Eric Dumazet was talking about with Florian
that stopped instantiating conntrack by default in new namespaces?

Just curious.
