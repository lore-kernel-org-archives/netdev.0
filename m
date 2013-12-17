From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] netfilter fixes for net
Date: Tue, 17 Dec 2013 15:07:17 -0500 (EST)
Message-ID: <20131217.150717.1189948201483822270.davem@davemloft.net>
References: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48621 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab3LQUHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 15:07:19 -0500
In-Reply-To: <1386959099-24582-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Fri, 13 Dec 2013 19:24:57 +0100

> The following patchset contains two Netfilter fixes for your net
> tree, they are:
> 
> * Fix endianness in nft_reject, the NFTA_REJECT_TYPE netlink attributes
>   was not converted to network byte order as needed by all nfnetlink
>   subsystems, from Eric Leblond.
> 
> * Restrict SYNPROXY target to INPUT and FORWARD chains, this avoid a
>   possible crash due to misconfigurations, from Patrick McHardy.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf.git master

Pulled, thanks Pablo.
