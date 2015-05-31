From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter updates for net-next
Date: Sun, 31 May 2015 00:02:51 -0700 (PDT)
Message-ID: <20150531.000251.1921501841931887903.davem@davemloft.net>
References: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39369 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754798AbbEaHCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 03:02:52 -0400
In-Reply-To: <1432856695-23831-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 29 May 2015 01:44:51 +0200

> The following patchset contains Netfilter updates for net-next, they are:
> 
> 1) default CONFIG_NETFILTER_INGRESS to y for easier compile-testing of all
>    options.
> 
> 2) Allow to bind a table to net_device. This introduces the internal
>    NFT_AF_NEEDS_DEV flag to perform a mandatory check for this binding.
>    This is required by the next patch.
> 
> 3) Add the 'netdev' table family, this new table allows you to create ingress
>    filter basechains. This provides access to the existing nf_tables features
>    from ingress.
> 
> 4) Kill unused argument from compat_find_calc_{match,target} in ip_tables
>    and ip6_tables, from Florian Westphal.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git

Pulled, thanks Pablo.
