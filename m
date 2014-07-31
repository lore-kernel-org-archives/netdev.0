From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net] tcp: Fix integer-overflow in TCP vegas
Date: Wed, 30 Jul 2014 17:31:47 -0700 (PDT)
Message-ID: <20140730.173147.1009537751381441905.davem@davemloft.net>
References: <1406634057-1289-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org,
	ncardwell@google.com, eric.dumazet@gmail.com,
	David.Laight@ACULAB.COM, doug.leith@nuim.ie
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37814 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755348AbaGaAbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 20:31:48 -0400
In-Reply-To: <1406634057-1289-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Tue, 29 Jul 2014 13:40:57 +0200

> In vegas we do a multiplication of the cwnd and the rtt. This
> may overflow and thus their result is stored in a u64. However, we first
> need to cast the cwnd so that actually 64-bit arithmetic is done.
> 
> Then, we need to do do_div to allow this to be used on 32-bit arches.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Neal Cardwell <ncardwell@google.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David Laight <David.Laight@ACULAB.COM>
> Cc: Doug Leith <doug.leith@nuim.ie>
> Fixes: 8d3a564da34e (tcp: tcp_vegas cong avoid fix)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied and queued up for -stable, thanks.
