From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 03 Apr 2012 19:20:07 -0400 (EDT)
Message-ID: <20120403.192007.615615439059523339.davem@davemloft.net>
References: <201204032128.JEG78136.JStMOHQOVFFFLO@I-love.SAKURA.ne.jp>
	<20120403125755.GA15339@1984>
	<20120403130620.GA15385@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: penguin-kernel@I-love.SAKURA.ne.jp, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39505 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCXVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 19:21:14 -0400
In-Reply-To: <20120403130620.GA15385@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 15:06:20 +0200

>>From 96a1ee814eef63a917e2a0af7a70bbf85511d285 Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Tue, 3 Apr 2012 14:50:07 +0200
> Subject: [PATCH] netfilter: xt_CT: fix missing put timeout object in error path
> 
> The error path misses putting the timeout object. This patch adds
> new function xt_ct_tg_timeout_put() to put the timeout object.
> 
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
