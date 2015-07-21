From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rhashtable: Allow other tasks to be
 scheduled in large lookup loops
Date: Tue, 21 Jul 2015 00:10:33 -0700 (PDT)
Message-ID: <20150721.001033.752659528477772835.davem@davemloft.net>
References: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mroos@linux.ee,
	herbert@gondor.apana.org.au, eric.dumazet@gmail.com
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55960 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbGUHKe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 03:10:34 -0400
In-Reply-To: <25527e380ed6701a3c73185e28f547d6e1d5907f.1437123031.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 17 Jul 2015 10:52:48 +0200

> Depending on system speed, the large lookup/insert/delete loops of the testsuite can
> take a considerable amount of time to complete causing watchdog warnings to appear.
> Allow other tasks to be scheduled throughout the loops.
> 
> Reported-by: Meelis Roos <mroos@linux.ee>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> ---
> v2: Use cond_resched() instead schedule()

Applied, thanks Thomas.
