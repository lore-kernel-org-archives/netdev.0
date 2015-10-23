From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: implement support for NOPREFIXROUTE ifa flag
 for ipv4 address
Date: Fri, 23 Oct 2015 02:55:20 -0700 (PDT)
Message-ID: <20151023.025520.942186208311911968.davem@davemloft.net>
References: <7decee4d1d1b71142460e604af6d15f0847ecd2d.1445329646.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33494 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750907AbbJWJiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 05:38:51 -0400
In-Reply-To: <7decee4d1d1b71142460e604af6d15f0847ecd2d.1445329646.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Tue, 20 Oct 2015 10:28:45 +0200

> Currently adding a new ipv4 address always cause the creation of the
> related network route, with default metric. When a host has multiple
> interfaces on the same network, multiple routes with the same metric
> are created.
> 
> If the userspace wants to set specific metric on each routes, i.e.
> giving better metric to ethernet links in respect to Wi-Fi ones,
> the network routes must be deleted and recreated, which is error-prone.
> 
> This patch implements the support for IFA_F_NOPREFIXROUTE for ipv4
> address. When an address is added with such flag set, no associated
> network route is created, no network route is deleted when
> said IP is gone and it's up to the user space manage such route.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied to net-next, thanks.
