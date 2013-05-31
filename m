From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 net-next] tcp: consolidate PRR packet accounting
Date: Thu, 30 May 2013 18:06:39 -0700 (PDT)
Message-ID: <20130530.180639.1613174002963842749.davem@davemloft.net>
References: <1369873214-29502-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, edumazet@google.com, nanditad@google.com,
	aterzis@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59802 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751999Ab3EaBGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 21:06:40 -0400
In-Reply-To: <1369873214-29502-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed, 29 May 2013 17:20:11 -0700

> This patch series fix an undo bug in fast recovery: the sender
> mistakenly undos the cwnd too early but continue fast retransmits
> until all pending data are acked. This also multiplicates the SNMP
> stat PARTIALUNDO events by the degree of the network reordering.
> 
> The first patch prepares the fix by consolidating the accounting
> of newly_acked_sacked in tcp_cwnd_reduction(), instead of updating
> newly_acked_sacked everytime sacked_out is adjusted.  Also pass
> acked and prior_unsacked as const type because they are readonly
> in the rest of recovery processing.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
