From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: Remove unnecessary arg from
 tcp_enter_cwr and tcp_init_cwnd_reduction
Date: Tue, 15 Jul 2014 16:19:46 -0700 (PDT)
Message-ID: <20140715.161946.1183860717468576831.davem@davemloft.net>
References: <1405349912-9593-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965213AbaGOXTr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 19:19:47 -0400
In-Reply-To: <1405349912-9593-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Mon, 14 Jul 2014 16:58:32 +0200

> Since Yuchung's 9b44190dc11 (tcp: refactor F-RTO), tcp_enter_cwr is always
> called with set_ssthresh = 1. Thus, we can remove this argument from
> tcp_enter_cwr. Further, as we remove this one, tcp_init_cwnd_reduction
> is then always called with set_ssthresh = true, and so we can get rid of
> this argument as well.
> 
> Cc: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied, thank you.
