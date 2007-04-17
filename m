From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [SCTP] Fix assertion
 (!atomic_read(&sk->sk_rmem_alloc)) failed message
Date: Tue, 17 Apr 2007 12:53:30 -0700 (PDT)
Message-ID: <20070417.125330.132931482.davem@davemloft.net>
References: <11762400848-git-send-email-vladislav.yasevich@hp.com>
	<11762400842444-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, t-fujii@nb.jp.nec.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57570
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1161126AbXDQTx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2007 15:53:28 -0400
In-Reply-To: <11762400842444-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 10 Apr 2007 17:21:23 -0400

> From: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
> 
> In current implementation, LKSCTP does receive buffer accounting for
> data in sctp_receive_queue and pd_lobby. However, LKSCTP don't do
> accounting for data in frag_list when data is fragmented. In addition,
> LKSCTP doesn't do accounting for data in reasm and lobby queue in
> structure sctp_ulpq.
> When there are date in these queue, assertion failed message is printed
> in inet_sock_destruct because sk_rmem_alloc of oldsk does not become 0
> when socket is destroyed.
> 
> Signed-off-by: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Patch applied.
