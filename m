From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Netfilter fixes for net-next
Date: Wed, 05 Oct 2016 20:26:12 -0400 (EDT)
Message-ID: <20161005.202612.688630151401011904.davem@davemloft.net>
References: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50864 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750792AbcJFA0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2016 20:26:18 -0400
In-Reply-To: <1475712469-17000-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu,  6 Oct 2016 02:07:44 +0200

> This is a pull request to address fallout from previous nf-next pull
> request, only fixes going on here:
> 
> 1) Address a potential null dereference in nf_unregister_net_hook()
>    when becomes nf_hook_entry_head is NULL, from Aaron Conole.
> 
> 2) Missing ifdef for CONFIG_NETFILTER_INGRESS, also from Aaron.
> 
> 3) Fix linking problems in xt_hashlimit in x86_32, from Pai.
> 
> 4) Fix permissions of nf_log sysctl from unpriviledge netns, from
>    Jann Horn.
> 
> 5) Fix possible divide by zero in nft_limit, from Liping Zhang.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks Pablo.
