From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] Netfilter fixes for net
Date: Wed, 19 Feb 2014 13:16:33 -0500 (EST)
Message-ID: <20140219.131633.393853748123176532.davem@davemloft.net>
References: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1392810102-13877-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed, 19 Feb 2014 12:41:36 +0100

> The following patchset contains Netfilter fixes for your net tree,
> they are:
> 
> * Fix nf_trace in nftables if XT_TRACE=n, from Florian Westphal.
> 
> * Don't use the fast payload operation in nf_tables if the length is
>   not power of 2 or it is not aligned, from Nikolay Aleksandrov.
> 
> * Fix missing break statement the inet flavour of nft_reject, which
>   results in evaluating IPv4 packets with the IPv6 evaluation routine,
>   from Patrick McHardy.
> 
> * Fix wrong kconfig symbol in nft_meta to match the routing realm,
>   from Paul Bolle.
> 
> * Allocate the NAT null binding when creating new conntracks via
>   ctnetlink to avoid that several packets race at initializing the
>   the conntrack NAT extension, original patch from Florian Westphal,
>   revisited version from me.
> 
> * Fix DNAT handling in the snmp NAT helper, the same handling was being
>   done for SNAT and DNAT and 2.4 already contains that fix, from
>   Francois-Xavier Le Bail.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks a lot Pablo.
