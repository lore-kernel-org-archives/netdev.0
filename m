From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: sctp_diag should fill RMEM_ALLOC with
 asoc->rmem_alloc when rcvbuf_policy is set
Date: Tue, 26 Apr 2016 15:19:33 -0400 (EDT)
Message-ID: <20160426.151933.1727797620994322847.davem@davemloft.net>
References: <f21861d502b04cf3752dce4cde8cd3f5f1806571.1461511282.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	marcelo.leitner@gmail.com, vyasevich@gmail.com,
	daniel@iogearbox.net, eric.dumazet@gmail.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607AbcDZTTf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:19:35 -0400
In-Reply-To: <f21861d502b04cf3752dce4cde8cd3f5f1806571.1461511282.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sun, 24 Apr 2016 23:21:22 +0800

> For sctp assoc, when rcvbuf_policy is set, it will has it's own
> rmem_alloc, when we dump asoc info in sctp_diag, we should use that
> value on RMEM_ALLOC as well, just like WMEM_ALLOC.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied.
