From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] ipv4: fib_select_default changes
Date: Fri, 24 Jul 2015 22:46:55 -0700 (PDT)
Message-ID: <20150724.224655.1032371032057252330.davem@davemloft.net>
References: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, hagen@jauu.net
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001AbbGYFdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 01:33:55 -0400
In-Reply-To: <1437551003-25537-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Wed, 22 Jul 2015 10:43:21 +0300

> This patchset contains 2 changes for the alternative routes,
> one to add tb_id/fa_slen check needed after the recent
> fib_trie optimizations for fib aliases and the second
> change attempts to support alternative routes with TOS
> requirement.
> 
> 	Sorry that I don't have access to the original
> report from Hagen Paul Pfeifer. I hope he will see this
> change.
> 
> 	The second change adds fa_default field to the
> fib aliases (which can be many) and if the feature to
> filter the alternative routes by TOS is not worth it,
> this second patch can be scrapped.

Great work, series applied, thanks Julian!
