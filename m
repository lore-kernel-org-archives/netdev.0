From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 next] r8169: add support for Byte Queue Limits
Date: Wed, 01 Oct 2014 16:36:05 -0400 (EDT)
Message-ID: <20141001.163605.2038993470978124920.davem@davemloft.net>
References: <1412163483-24560-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, hayeswang@realtek.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36469 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752286AbaJAUgH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 16:36:07 -0400
In-Reply-To: <1412163483-24560-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Wed,  1 Oct 2014 13:38:03 +0200

> tested on RTL8168d/8111d model using 'super_netperf 40' with TCP/UDP_STREAM.
> 
> Output of
> while true; do
>     for n in inflight limit; do
>           echo -n $n\ ; cat $n;
>     done;
>     sleep 1;
> done
 ...
> [end of test]
> 
> Cc: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Hayes Wang <hayeswang@realtek.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> Acked-by: Eric Dumazet <edumazet@google.com>
> Acked-by: Tom Herbert <therbert@google.com>
> ---
>  Change since v2: updated commit message.

Applied, thank you.
