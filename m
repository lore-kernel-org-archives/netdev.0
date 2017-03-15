From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/10] Netfilter fixes for net
Date: Wed, 15 Mar 2017 15:13:33 -0700 (PDT)
Message-ID: <20170315.151333.218009816666550263.davem@davemloft.net>
References: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdCOWNf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:13:35 -0400
In-Reply-To: <1489597272-30347-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 15 Mar 2017 18:01:02 +0100

> The following patchset contains Netfilter fixes for your net tree, a
> rather large batch of fixes targeted to nf_tables, conntrack and bridge
> netfilter. More specifically, they are:
> 
> 1) Don't track fragmented packets if the socket option IP_NODEFRAG is set.
>    From Florian Westphal.
> 
> 2) SCTP protocol tracker assumes that ICMP error messages contain the
>    checksum field, what results in packet drops. From Ying Xue.
> 
> 3) Fix inconsistent handling of AH traffic from nf_tables.
> 
> 4) Fix new bitmap set representation with big endian. Fix mismatches in
>    nf_tables due to incorrect big endian handling too. Both patches
>    from Liping Zhang.
> 
> 5) Bridge netfilter doesn't honor maximum fragment size field, cap to
>    largest fragment seen. From Florian Westphal.
> 
> 6) Fake conntrack entry needs to be aligned to 8 bytes since the 3 LSB
>    bits are now used to store the ctinfo. From Steven Rostedt.
> 
> 7) Fix element comments with the bitmap set type. Revert the flush
>    field in the nft_set_iter structure, not required anymore after
>    fixing up element comments.
> 
> 8) Missing error on invalid conntrack direction from nft_ct, also from
>    Liping Zhang.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git

Pulled, thanks Pablo!
