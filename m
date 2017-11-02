From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] Netfilter fixes for net
Date: Thu, 02 Nov 2017 16:53:24 +0900 (KST)
Message-ID: <20171102.165324.2030914010084825057.davem@davemloft.net>
References: <20171101184812.4813-1-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44896 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750907AbdKBHx1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 03:53:27 -0400
In-Reply-To: <20171101184812.4813-1-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed,  1 Nov 2017 19:48:10 +0100

> The following patchset contains two one-liner fixes for your net tree,
> they are:
> 
> 1) Disable fast hash operations for 2-bytes length keys which is leading
>    to incorrect lookups in nf_tables, from Anatole Denis.
> 
> 2) Reload pointer ipv4 header after ip_route_me_harder() given this may
>    result in use-after-free due to skbuff header reallocation, patch
>    from Tejaswi Tanikella.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks a lot Pablo.
