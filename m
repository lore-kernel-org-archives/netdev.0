From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7] net: ipv6: Make address flushing on ifdown
 optional
Date: Thu, 25 Feb 2016 21:45:37 -0500 (EST)
Message-ID: <20160225.214537.1334107695744344694.davem@davemloft.net>
References: <1456334737-16708-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hideaki.yoshifuji@miraclelinux.com,
	hannes@stressinduktion.org
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49101 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbcBZCpn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 21:45:43 -0500
In-Reply-To: <1456334737-16708-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Wed, 24 Feb 2016 09:25:37 -0800

> Currently, all ipv6 addresses are flushed when the interface is configured
> down, including global, static addresses:
 ...
> Add a new sysctl to make this behavior optional. The new setting defaults to
> flush all addresses to maintain backwards compatibility. When the set global
> addresses with no expire times are not flushed on an admin down. The sysctl
> is per-interface or system-wide for all interfaces
> 
>     $ sysctl -w net.ipv6.conf.eth1.keep_addr_on_down=1
> or
>     $ sysctl -w net.ipv6.conf.all.keep_addr_on_down=1
> 
> Will keep addresses on eth1 on an admin down.
 ...
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>

Applied, thanks for your persistence David :)
