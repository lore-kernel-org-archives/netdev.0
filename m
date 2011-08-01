From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Mon, 01 Aug 2011 02:27:37 -0700 (PDT)
Message-ID: <20110801.022737.74290317435199544.davem@davemloft.net>
References: <1311948052.2843.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<4E32BF87.6010909@trash.net>
	<1312003362.2873.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, soltys@ziu.info, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	hadi@cyberus.ca, lucas.bocchi@gmail.com, 631945@bugs.debian.org,
	00bormoj@gmail.com, fdelawarde@wirelessmundi.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:42875 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751254Ab1HAJ2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 05:28:55 -0400
In-Reply-To: <1312003362.2873.54.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 30 Jul 2011 07:22:42 +0200

> [PATCH] sch_sfq: fix sfq_enqueue()
> 
> commit 8efa88540635 (sch_sfq: avoid giving spurious NET_XMIT_CN signals)
> forgot to call qdisc_tree_decrease_qlen() to signal upper levels that a
> packet (from another flow) was dropped, leading to various problems. 
> 
> With help from Michal Soltys and Michal Pokrywka, who did a bisection.
> 
> Bugzilla ref: https://bugzilla.kernel.org/show_bug.cgi?id=39372
> Debian ref: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=631945
> 
> Reported-by: Lucas Bocchi <lucas.bocchi@gmail.com>
> Reported-and-bisected-by: Michal Pokrywka <wolfmoon@o2.pl>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Michal Soltys <soltys@ziu.info>
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied, thanks.
