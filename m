From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: reset timer after any SYNACK retransmit
Date: Mon, 29 Apr 2013 15:17:48 -0400 (EDT)
Message-ID: <20130429.151748.2089724181218333468.davem@davemloft.net>
References: <1367261091-28052-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, hagen@jauu.net,
	netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33398 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760558Ab3D2TRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 15:17:50 -0400
In-Reply-To: <1367261091-28052-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Mon, 29 Apr 2013 11:44:51 -0700

> Linux immediately returns SYNACK on (spurious) SYN retransmits, but
> keeps the SYNACK timer running independently. Thus the timer may
> fire right after the SYNACK retransmit and causes a SYN-SYNACK
> cross-fire burst.
> 
> Adopt the fast retransmit/recovery idea in established state by
> re-arming the SYNACK timer after the fast (SYNACK) retransmit. The
> timer may fire late up to 500ms due to the current SYNACK timer wheel,
> but it's OK to be conservative when network is congested. Eric's new
> listener design should address this issue.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.

Maybe -stable material?
