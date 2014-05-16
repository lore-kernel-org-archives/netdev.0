From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2014-05-15
Date: Thu, 15 May 2014 23:25:16 -0400 (EDT)
Message-ID: <20140515.232516.1168321577530105610.davem@davemloft.net>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752290AbaEPDZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 23:25:18 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 15 May 2014 09:07:50 +0200

> This pull request has a merge conflict in net/ipv4/ip_vti.c
> between commit 8d89dcdf80d8 ("vti: don't allow to add the same
> tunnel twice") and commit a32452366b72  ("vti4:Don't count header
> length twice"). It can be solved like it is done in linux-next.
> 
> 1) Fix a ipv6 xfrm output crash when a packet is rerouted
>    by netfilter to not use IPsec.
> 
> 2) vti4 counts some header lengths twice leading to an incorrect
>    device mtu. Fix this by counting these headers only once.
> 
> 3) We don't catch the case if an unsupported protocol is submitted
>    to the xfrm protocol handlers, this can lead to NULL pointer
>    dereferences. Fix this by adding the appropriate checks.
> 
> 4) vti6 may unregister pernet ops twice on init errors.
>    Fix this by removing one of the calls to do it only once.
>    From Mathias Krause.
> 
> 5) Set the vti tunnel mark before doing a lookup in the error
>    handlers. Otherwise we don't find the correct xfrm state.
> 
> Please pull or let me know if there are problems.

Pulled, thanks a lot Steffen.
