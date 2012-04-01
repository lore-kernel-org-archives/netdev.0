From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix array index in ip6_mc_add_src()
Date: Sun, 01 Apr 2012 15:13:18 -0400 (EDT)
Message-ID: <20120401.151318.984514868716173152.davem@davemloft.net>
References: <1333269926-24681-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752918Ab2DATNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Apr 2012 15:13:20 -0400
In-Reply-To: <1333269926-24681-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Sun,  1 Apr 2012 16:45:26 +0800

> From: RongQing.Li <roy.qing.li@gmail.com>
> 
> Convert array index from the loop bound to the loop index.
> 
> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com> 

That's not all you are doing:

> -			(void) ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
> +			ip6_mc_del1_src(pmc, sfmode, &psfsrc[j]);

You absolutely MUST mention and explain this (void) removal.
It's probably there to elide an unchecked return value
warning from the compiler.
