From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [PATCH net] tcp: Fix divide by zero when pushing during tcp-repair
Date: Mon, 30 Jun 2014 17:12:25 +0400
Message-ID: <53B16239.80402@parallels.com>
References: <1403972797-15285-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Andrew Vagin <avagin@openvz.org>
To: Christoph Paasch <christoph.paasch@uclouvain.be>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:35592 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754073AbaF3NMb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2014 09:12:31 -0400
In-Reply-To: <1403972797-15285-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/28/2014 08:26 PM, Christoph Paasch wrote:
> When in repair-mode and TCP_RECV_QUEUE is set, we end up calling
> tcp_push with mss_now being 0. If data is in the send-queue and
> tcp_set_skb_tso_segs gets called, we crash because it will divide by
> mss_now:
> 
snip
> Cc: Andrew Vagin <avagin@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Fixes: ec3423257508 (tcp: fix retransmission in repair mode)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Acked-by: Pavel Emelyanov <xemul@parallels.com>

Thanks,
Pavel
