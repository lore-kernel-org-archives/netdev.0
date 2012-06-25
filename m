From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] tcp: plug dst leak in tcp_v6_conn_request()
Date: Mon, 25 Jun 2012 16:06:03 -0700 (PDT)
Message-ID: <20120625.160603.2046472954169103270.davem@davemloft.net>
References: <1340515324-2152-5-git-send-email-ncardwell@google.com>
	<1340523678.23933.11.camel@edumazet-glaptop>
	<CADVnQykuAQcj_i5cZQphKnnoHaCPMd6xLBmq1ZSAeZs83z3tfw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	edumazet@google.com, therbert@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756830Ab2FYXGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jun 2012 19:06:03 -0400
In-Reply-To: <CADVnQykuAQcj_i5cZQphKnnoHaCPMd6xLBmq1ZSAeZs83z3tfw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Sun, 24 Jun 2012 13:12:33 -0400

> Yes, the patches in this series were generated as patches against the
> "net" tree (sorry for not indicating that).
> 
> The dst leak on the v6 sysctl_tw_recycle code path (patches 2-5) seems
> like a pretty low priority, so I think we could simplify your plan
> even a little further... How about this as a plan: we could apply the
> first patch in the series (tcp: heed result of
> security_inet_conn_request() in tcp_v6_conn_request()) to the net tree
> now, and skip patches 2-5 for now. Once your pending synack work is in
> net-next, I can respin patches 2-5 for net-next. How does that sound?

I've applied the first patch to 'net' and you can simply respin
your patches against net-next right now since I rejected Eric's
SYN-ACK patches.
