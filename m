From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] ipip: potential race in ip_tunnel_init_net()
Date: Sun, 25 Aug 2013 18:40:19 -0400 (EDT)
Message-ID: <20130825.184019.2151038981865894784.davem@davemloft.net>
References: <20130820.233301.985050199020241179.davem@davemloft.net>
	<20130823081537.GB31293@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, eric.dumazet@gmail.com
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641Ab3HYWkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Aug 2013 18:40:21 -0400
In-Reply-To: <20130823081537.GB31293@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 23 Aug 2013 11:15:37 +0300

> Eric Dumazet says that my previous fix for an ERR_PTR dereference
> (ea857f28ab 'ipip: dereferencing an ERR_PTR in ip_tunnel_init_net()')
> could be racy and suggests the following fix instead.
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
