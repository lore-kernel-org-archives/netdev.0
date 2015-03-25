From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/5] tcp: listener refactor part 16
Date: Tue, 24 Mar 2015 21:18:32 -0400 (EDT)
Message-ID: <20150324.211832.684336006405198659.davem@davemloft.net>
References: <1427237936-19030-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: edumazet@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830AbbCYBSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 21:18:37 -0400
In-Reply-To: <1427237936-19030-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>
Date: Tue, 24 Mar 2015 15:58:51 -0700

> A CONFIG_PROVE_RCU=y build revealed an RCU splat I had to fix.
> 
> I added const qualifiers to various md5 methods, as I expect
> to call them on behalf of request sock traffic even if
> the listener socket is not locked. This seems ok, but adding
> const makes the contract clearer. Note a good reduction
> of code size thanks to request/establish sockets convergence.

Series applied, thanks Eric.
