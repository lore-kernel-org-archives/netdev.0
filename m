From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: inet_diag: export IPV6_V6ONLY sockopt
Date: Wed, 24 Jun 2015 02:51:52 -0700 (PDT)
Message-ID: <20150624.025152.1145614139930184404.davem@davemloft.net>
References: <1435136571-18879-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39415 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751160AbbFXJkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2015 05:40:01 -0400
In-Reply-To: <1435136571-18879-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Wed, 24 Jun 2015 11:02:51 +0200

> For AF_INET6 sockets, the value of struct ipv6_pinfo.ipv6only is
> exported to userspace. It indicates whether a socket bound to in6addr_any
> listens on IPv4 as well as IPv6. Since the socket is natively IPv6, it is not
> listed by e.g. 'ss -l -4'.
> 
> This patch is accompanied by an appropriate one for iproute2 to enable
> the additional information in 'ss -e'.
> 
> Signed-off-by: Phil Sutter <phil@nwl.cc>

Applied, thanks.
