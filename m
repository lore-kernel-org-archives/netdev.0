From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] pkt_sched: move the sanity test in qdisc_list_add()
Date: Mon, 10 Mar 2014 15:44:43 -0400 (EDT)
Message-ID: <20140310.154443.2004305018874618616.davem@davemloft.net>
References: <7625.1387476879@turing-police.cc.vt.edu>
	<1387556764.19078.441.camel@edumazet-glaptop2.roam.corp.google.com>
	<1394294479.20149.66.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, mt-ml@gmx.de, edumazet@google.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752304AbaCJToq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 15:44:46 -0400
In-Reply-To: <1394294479.20149.66.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 08 Mar 2014 08:01:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> The WARN_ON(root == &noop_qdisc)) added in qdisc_list_add()
> can trigger in normal conditions when devices are not up.
> It should be done only right before the list_add_tail() call.
> 
> Fixes: e57a784d8cae4 ("pkt_sched: set root qdisc before change() in attach_default_qdiscs()")
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> Tested-by: Mirco Tischler <mt-ml@gmx.de>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
