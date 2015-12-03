From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pppox: use standard module auto-loading feature
Date: Thu, 03 Dec 2015 15:14:00 -0500 (EST)
Message-ID: <20151203.151400.1781943336832572536.davem@davemloft.net>
References: <02bfd73648a0cf563213d58daefe8b8de580a70a.1449067422.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xeb@mail.ru, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45477 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753440AbbLCUOB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:14:01 -0500
In-Reply-To: <02bfd73648a0cf563213d58daefe8b8de580a70a.1449067422.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Wed, 2 Dec 2015 16:27:39 +0100

>   * Register PF_PPPOX with pppox module rather than with pppoe,
>     so that pppoe doesn't get loaded for any PF_PPPOX socket.
> 
>   * Register PX_PROTO_* with standard MODULE_ALIAS_NET_PF_PROTO()
>     instead of using pppox's own naming scheme.
> 
>   * While there, add auto-loading feature for pptp.
> 
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied, thanks.
