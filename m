From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] Netfilter/IPVS fixes for net
Date: Mon, 02 Feb 2015 19:31:45 -0800 (PST)
Message-ID: <20150202.193145.1304706351100754751.davem@davemloft.net>
References: <1422737711-5169-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50269 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751753AbbBCDbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 22:31:46 -0500
In-Reply-To: <1422737711-5169-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 31 Jan 2015 21:55:07 +0100

> The following patchset contains Netfilter/IPVS fixes for your net tree,
> they are:
> 
> 1) Validate hooks for nf_tables NAT expressions, otherwise users can
>    crash the kernel when using them from the wrong hook. We already
>    got one user trapped on this when configuring masquerading.
> 
> 2) Fix a BUG splat in nf_tables with CONFIG_DEBUG_PREEMPT=y. Reported
>    by Andreas Schultz.
> 
> 3) Avoid unnecessary reroute of traffic in the local input path
>    in IPVS that triggers a crash in in xfrm. Reported by Florian
>    Wiessner and fixes by Julian Anastasov.
> 
> 4) Fix memory and module refcount leak from the error path of
>    nf_tables_newchain().

Pulled, thanks Pablo.
