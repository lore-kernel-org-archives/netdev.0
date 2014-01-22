From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tcp: delete redundant calls of tcp_mtup_init()
Date: Tue, 21 Jan 2014 16:52:57 -0800 (PST)
Message-ID: <20140121.165257.1474926702945114111.davem@davemloft.net>
References: <20140114.164105.524133214769947013.davem@davemloft.net>
	<1a8e9e92721ef792aa017b89a4d6376dca5dc4f6.1390135376.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: panweiping3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38709 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752677AbaAVAw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 19:52:57 -0500
In-Reply-To: <1a8e9e92721ef792aa017b89a4d6376dca5dc4f6.1390135376.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <panweiping3@gmail.com>
Date: Sun, 19 Jan 2014 20:44:46 +0800

> As tcp_rcv_state_process() has already calls tcp_mtup_init() for non-fastopen
> sock, we can delete the redundant calls of tcp_mtup_init() in
> tcp_{v4,v6}_syn_recv_sock().
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>

Looks good, applied.
