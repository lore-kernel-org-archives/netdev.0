From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] ip_forward: Drop frames with attached skb->sk
Date: Mon, 20 Apr 2015 14:08:25 -0400 (EDT)
Message-ID: <20150420.140825.121616346767140780.davem@davemloft.net>
References: <1429514360.7091.9.camel@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sebastian.poehn@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbbDTSIa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2015 14:08:30 -0400
In-Reply-To: <1429514360.7091.9.camel@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sebastian Poehn <sebastian.poehn@gmail.com>
Date: Mon, 20 Apr 2015 09:19:20 +0200

> Initial discussion was:
> [FYI] xfrm: Don't lookup sk_policy for timewait sockets
> 
> Forwarded frames should not have a socket attached. Especially
> tw sockets will lead to panics later-on in the stack.
> 
> This was observed with TPROXY assigning a tw socket and broken
> policy routing (misconfigured). As a result frame enters
> forwarding path instead of input. We cannot solve this in
> TPROXY as it cannot know that policy routing is broken.
> 
> v2:
> Remove useless comment
> 
> Signed-off-by: Sebastian Poehn <sebastian.poehn@gmail.com>

Applied and queued up for -stable, thanks Sebastian.
