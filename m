From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 03 Apr 2012 19:21:08 -0400 (EDT)
Message-ID: <20120403.192108.193111996343981139.davem@davemloft.net>
References: <20120403130620.GA15385@1984>
	<201204032328.CDE78687.tQOHSLVFOFMJOF@I-love.SAKURA.ne.jp>
	<20120403145210.GA31196@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39511 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCXWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:22:15 -0400
In-Reply-To: <20120403145210.GA31196@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 16:52:10 +0200

>>From 0fca4d604c0898128014bc03ef965e0cf187a5e9 Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 3 Apr 2012 16:45:54 +0200
> Subject: [PATCH] netfilter: nf_conntrack: fix count leak in error path of __nf_conntrack_alloc
> 
> We have to decrement the conntrack counter if we fail to access the
> zone extension.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
