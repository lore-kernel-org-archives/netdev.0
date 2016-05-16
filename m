From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: also make sch_handle_egress() drop
 monitor ready
Date: Mon, 16 May 2016 14:03:10 -0400 (EDT)
Message-ID: <20160516.140310.1776883472080796642.davem@davemloft.net>
References: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, alexei.starovoitov@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37155 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753854AbcEPSDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:03:12 -0400
In-Reply-To: <94bae5636d86c039a0cfee3aa4876fc7bcde2eef.1463347152.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Sun, 15 May 2016 23:28:29 +0200

> Follow-up for 8a3a4c6e7b34 ("net: make sch_handle_ingress() drop
> monitor ready") to also make the egress side drop monitor ready.
> 
> Also here only TC_ACT_SHOT is a clear indication that something
> went wrong. Hence don't provide false positives to drop monitors
> such as 'perf record -e skb:kfree_skb ...'.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
