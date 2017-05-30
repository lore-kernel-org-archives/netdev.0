From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter fixes for net
Date: Mon, 29 May 2017 23:20:48 -0400 (EDT)
Message-ID: <20170529.232048.1583898671889129502.davem@davemloft.net>
References: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45484 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750839AbdE3DUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 29 May 2017 23:20:53 -0400
In-Reply-To: <1496057672-6751-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 29 May 2017 13:34:28 +0200

> Hi David,
> 
> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> 1) Conntrack SCTP CRC32c checksum mangling may operate on non-linear
>    skbuff, patch from Davide Caratti.
> 
> 2) nf_tables rb-tree set backend does not handle element re-addition
>    after deletion in the same transaction, leading to infinite loop.
> 
> 3) Atomically unclear the IPS_SRC_NAT_DONE_BIT on nat module removal,
>    from Liping Zhang.
> 
> 4) Conntrack hashtable resizing while ctnetlink dump is progress leads
>    to a dead reference to released objects in the lists, also from
>    Liping.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks a lot Pablo.
