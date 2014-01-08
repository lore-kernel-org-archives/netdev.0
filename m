From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] Netfilter updates for net-next
Date: Wed, 08 Jan 2014 15:05:20 -0500 (EST)
Message-ID: <20140108.150520.477424270812121491.davem@davemloft.net>
References: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52929 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbaAHUFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 15:05:23 -0500
In-Reply-To: <1389208404-3956-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Wed,  8 Jan 2014 20:13:21 +0100

> The following patchset contains three Netfilter updates, they are:
> 
> * Fix wrong usage of skb_header_pointer in the DCCP protocol helper that
>   has been there for quite some time. It was resulting in copying the dccp
>   header to a pointer allocated in the stack. Fortunately, this pointer
>   provides room for the dccp header is 4 bytes long, so no crashes have been
>   reported so far. From Daniel Borkmann.
> 
> * Use format string to print in the invocation of nf_log_packet(), again
>   in the DCCP helper. Also from Daniel Borkmann.
> 
> * Revert "netfilter: avoid get_random_bytes call" as prandom32 does not
>   guarantee enough entropy when being calling this at boot time, that may
>   happen when reloading the rule.
> 
> You can pull these changes from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/pablo/nf-next.git master

Pulled, thanks Pablo.
