From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] rds-tcp: Add module parameters to control
 sndbuf/rcvbuf size of RDS-TCP socket
Date: Mon, 14 Mar 2016 14:59:08 -0400 (EDT)
Message-ID: <20160314.145908.253635091290932699.davem@davemloft.net>
References: <20160312043952.GC26486@oracle.com>
	<CALx6S37m5s+6h4v1gKiBv2e2p+Ft9Ub4g-YLREWe=A5iuZAseA@mail.gmail.com>
	<20160314180642.GI5084@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, stephen@networkplumber.org,
	netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362AbcCNS7K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 14:59:10 -0400
In-Reply-To: <20160314180642.GI5084@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Mon, 14 Mar 2016 14:06:42 -0400

> However, it would still be nice to know exactly what distribution
> issues come out of modparam.

Module parameters mean unstable interfaces, and provide inconsistent
ways to do the same exact thing from driver to driver and protocol to
protocol.

Do not use them, ever.
