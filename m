From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Tue, 02 Apr 2013 14:37:55 -0400 (EDT)
Message-ID: <20130402.143755.2007878338808163006.davem@davemloft.net>
References: <515976BE.6060607@gmail.com>
	<515996CF.3030809@linux-ipv6.org>
	<515AB6B1.4080501@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, eric.dumazet@gmail.com, kaber@trash.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760910Ab3DBSiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 14:38:00 -0400
In-Reply-To: <515AB6B1.4080501@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Tue, 02 Apr 2013 16:15:05 +0530

> IPv6 Routing table becomes broken once we do ifdown, ifup of the loopback(lo)
> interface. After down-up, routes of other interface's IPv6 addresses through
> 'lo' are lost.
> 
> IPv6 addresses assigned to all interfaces are routed through 'lo' for internal
> communication. Once 'lo' is down, those routing entries are removed from routing
> table. But those removed entries are not being re-created properly when 'lo' is
> brought up. So IPv6 addresses of other interfaces becomes unreachable from the
> same machine. Also this breaks communication with other machines because of
> NDISC packet processing failure.
> 
> This patch fixes this issue by reading all interface's IPv6 addresses and adding
> them to IPv6 routing table while bringing up 'lo'.
> 
> Patch is prepared for Linux-3.9.rc5 kernel.
> 
> Signed-off-by: Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>
> Signed-off-by: Maruthi Thotad <Maruthi.Thotad@ap.sony.com>

Applied, thanks.
