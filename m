From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/3] bridge: Base the BR_PROXYARP decision on the
 target port flag
Date: Sat, 07 Feb 2015 21:59:22 -0800 (PST)
Message-ID: <20150207.215922.1914777712701024499.davem@davemloft.net>
References: <1423130063-18323-1-git-send-email-jouni@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kyeyoonp@codeaurora.org
To: jouni@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922AbbBHF7X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 00:59:23 -0500
In-Reply-To: <1423130063-18323-1-git-send-email-jouni@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jouni Malinen <jouni@codeaurora.org>
Date: Thu,  5 Feb 2015 11:54:21 +0200

> From: Kyeyoon Park <kyeyoonp@codeaurora.org>
> 
> When doing proxy ARP, instead of checking the bridge port flag for
> BR_PROXYARP on the bridge port on which the frame was received, check
> the bridge port flag of the bridge port to which the target device
> belongs.
> 
> Signed-off-by: Kyeyoon Park <kyeyoonp@codeaurora.org>
> Signed-off-by: Jouni Malinen <jouni@codeaurora.org>
> ---
> v2: Address Stephen's comment on mixing && and & without parens
>     and check for f->dst != NULL before dereferencing it

This is a semantic change, what if the administrator wanted the
current behavior?

I'm not applying this.  If you want the new behavior, it will have
to be at a minimum turned on via a sysctl that defaults to OFF.
