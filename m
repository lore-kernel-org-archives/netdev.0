From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RESEND] pkt_sched: sch_qfq: remove redundant -if-
 control statement
Date: Sun, 21 Jun 2015 09:48:13 -0700 (PDT)
Message-ID: <20150621.094813.2149203024416614613.davem@davemloft.net>
References: <1434493019-5762-1-git-send-email-parri.andrea@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, paolo.valente@unimore.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: parri.andrea@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46510 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751861AbbFUQg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jun 2015 12:36:27 -0400
In-Reply-To: <1434493019-5762-1-git-send-email-parri.andrea@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrea Parri <parri.andrea@gmail.com>
Date: Wed, 17 Jun 2015 00:16:59 +0200

> The control !hlist_unhashed() in qfq_destroy_agg() is unnecessary
> because already performed in hlist_del_init(), so remove it.
> 
> Signed-off-by: Andrea Parri <parri.andrea@gmail.com>

Applied.
