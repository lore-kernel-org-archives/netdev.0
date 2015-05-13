From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pktgen: fix packet generation
Date: Tue, 12 May 2015 23:10:10 -0400 (EDT)
Message-ID: <20150512.231010.589810946107816228.davem@davemloft.net>
References: <1431382788-6051-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, edumazet@google.com, daniel@iogearbox.net,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49046 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933961AbbEMDKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 23:10:11 -0400
In-Reply-To: <1431382788-6051-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Mon, 11 May 2015 15:19:48 -0700

> pkt_gen->last_ok was not set properly, so after the first burst
> pktgen instead of allocating new packet, will reuse old one, advance
> eth_type_trans further, which would mean the stack will be seeing very
> short bogus packets.
> 
> Fixes: 62f64aed622b ("pktgen: introduce xmit_mode '<start_xmit|netif_receive>'")
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Applied, thanks for this fix.
