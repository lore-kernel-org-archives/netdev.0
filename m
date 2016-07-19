From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched/sch_htb: clamp xstats tokens to fit into
 32-bit int
Date: Mon, 18 Jul 2016 22:45:39 -0700 (PDT)
Message-ID: <20160718.224539.1775569403422486926.davem@davemloft.net>
References: <146867813621.23552.6234170020058724059.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org
To: khlebnikov@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932AbcGSFpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 01:45:40 -0400
In-Reply-To: <146867813621.23552.6234170020058724059.stgit@buzz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Sat, 16 Jul 2016 17:08:56 +0300

> In kernel HTB keeps tokens in signed 64-bit in nanoseconds. In netlink
> protocol these values are converted into pshed ticks (64ns for now) and
> truncated to 32-bit. In struct tc_htb_xstats fields "tokens" and "ctokens"
> are declared as unsigned 32-bit but they could be negative thus tool 'tc'
> prints them as signed. Big values loose higher bits and/or become negative.
> 
> This patch clamps tokens in xstat into range from INT_MIN to INT_MAX.
> In this way it's easier to understand what's going on here.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
