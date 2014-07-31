From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESUBMIT net] tcp: Fix integer-overflows in TCP veno
Date: Wed, 30 Jul 2014 17:31:34 -0700 (PDT)
Message-ID: <20140730.173134.865256818780740961.davem@davemloft.net>
References: <1406628447-21130-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101AbaGaAbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 20:31:35 -0400
In-Reply-To: <1406628447-21130-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 29 Jul 2014 12:07:27 +0200

> In veno we do a multiplication of the cwnd and the rtt. This
> may overflow and thus their result is stored in a u64. However, we first
> need to cast the cwnd so that actually 64-bit arithmetic is done.
> 
> A first attempt at fixing 76f1017757aa0 ([TCP]: TCP Veno congestion
> control) was made by 159131149c2 (tcp: Overflow bug in Vegas), but it
> failed to add the required cast in tcp_veno_cong_avoid().
> 
> Fixes: 76f1017757aa0 ([TCP]: TCP Veno congestion control)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied and queued up for -stable.
