From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/9] Netfilter/IPVS fixes for net
Date: Fri, 08 Sep 2017 11:36:13 -0700 (PDT)
Message-ID: <20170908.113613.678386423137863254.davem@davemloft.net>
References: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756619AbdIHSgO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 14:36:14 -0400
In-Reply-To: <1504892748-1605-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri,  8 Sep 2017 19:45:39 +0200

> The following patchset contains Netfilter/IPVS fixes for your net tree,
> they are:
> 
> 1) Fix SCTP connection setup when IPVS module is loaded and any scheduler
>    is registered, from Xin Long.
> 
> 2) Don't create a SCTP connection from SCTP ABORT packets, also from
>    Xin Long.
> 
> 3) WARN_ON() and drop packet, instead of BUG_ON() races when calling
>    nf_nat_setup_info(). This is specifically a longstanding problem
>    when br_netfilter with conntrack support is in place, patch from
>    Florian Westphal.
> 
> 4) Avoid softlock splats via iptables-restore, also from Florian.
> 
> 5) Revert NAT hashtable conversion to rhashtable, semantics of rhlist
>    are different from our simple NAT hashtable, this has been causing
>    problems in the recent Linux kernel releases. From Florian.
> 
> 6) Add per-bucket spinlock for NAT hashtable, so at least we restore
>    one of the benefits we got from the previous rhashtable conversion.
> 
> 7) Fix incorrect hashtable size in memory allocation in xt_hashlimit,
>    from Zhizhou Tian.
> 
> 8) Fix build/link problems with hashlimit and 32-bit arches, to address
>    recent fallout from a new hashlimit mode, from Vishwanath Pai.

Pulled, thanks Pablo.
