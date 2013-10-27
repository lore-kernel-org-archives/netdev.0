From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: only take RTT from timestamps if new data is
 acked
Date: Sun, 27 Oct 2013 16:51:45 -0400 (EDT)
Message-ID: <20131027.165145.1610383415582119785.davem@davemloft.net>
References: <1382630125-21416-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53880 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753229Ab3J0Uvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:51:47 -0400
In-Reply-To: <1382630125-21416-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Thu, 24 Oct 2013 08:55:25 -0700

> Patch ed08495c3 "tcp: use RTT from SACK for RTO" has a bug that
> it does not check if the ACK acknowledge new data before taking
> the RTT sample from TCP timestamps. This patch adds the check
> back as required by the RFC.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied and queued up for -stable.
